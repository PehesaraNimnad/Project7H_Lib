local isQb = Config.Framework == 'qb' or (Config.Framework == 'auto' and checkResource('qb-core'))
local isQbox = Config.Framework == 'qbox' or (Config.Framework == 'auto' and not checkResource('qb-core') and checkResource('qbx_core'))

if not isQb and not isQbox then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info(('[Vehicles] Loaded: %s (player_vehicles)'):format(isQbox and 'QBOX' or 'QB'))
end

P7H.Vehicles = {}
P7H.Vehicles.TableName = 'player_vehicles'

local EXTRA_COLUMNS = {
    { name = 'nickname', definition = 'VARCHAR(64) NULL DEFAULT NULL' },
    { name = 'favorite', definition = 'TINYINT(1) NOT NULL DEFAULT 0' },
    { name = 'impound_data', definition = 'LONGTEXT NULL DEFAULT NULL' },
}

local function columnExists(column)
    local count = MySQL.scalar.await(
        'SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?',
        { P7H.Vehicles.TableName, column }
    )
    return (count or 0) > 0
end

P7H.Vehicles.EnsureSchema = function()
    for _, col in ipairs(EXTRA_COLUMNS) do
        if not columnExists(col.name) then
            MySQL.query.await(('ALTER TABLE `%s` ADD COLUMN `%s` %s'):format(P7H.Vehicles.TableName, col.name, col.definition))
        end
    end
end

CreateThread(function()
    P7H.Vehicles.EnsureSchema()
end)

local function getPlayer(playerId)
    if isQbox then
        return exports['qbx_core']:GetPlayer(playerId)
    end
    return QBCore.Functions.GetPlayer(playerId)
end

local function trim(value)
    return (value or ''):match('^%s*(.-)%s*$')
end

local function decodeJson(value)
    if type(value) ~= 'string' or value == '' then return nil end
    local ok, decoded = pcall(json.decode, value)
    return ok and decoded or nil
end

local function toPercent(health)
    return math.max(0, math.min(100, math.floor((health or 1000) / 10)))
end

local function normalize(row)
    local impound = decodeJson(row.impound_data)

    local state = 'out'
    if impound or row.state == 2 then
        state = 'impounded'
    elseif row.state == 1 then
        state = 'garaged'
    end

    return {
        plate = trim(row.plate),
        owner = row.citizenid,
        model = row.vehicle,
        props = decodeJson(row.mods) or {},
        garage = row.garage,
        state = state,
        fuel = math.max(0, math.min(100, math.floor(row.fuel or 100))),
        engine = toPercent(row.engine),
        body = toPercent(row.body),
        mileage = row.drivingdistance or 0,
        nickname = row.nickname,
        favorite = (row.favorite or 0) == 1,
        impound = impound,
    }
end

P7H.Vehicles.GetPlayerVehicles = function(uniqueId)
    local rows = MySQL.query.await('SELECT * FROM `player_vehicles` WHERE `citizenid` = ?', { uniqueId }) or {}
    local vehicles = {}
    for _, row in ipairs(rows) do
        vehicles[#vehicles + 1] = normalize(row)
    end
    return vehicles
end

P7H.Vehicles.GetVehicleByPlate = function(plate)
    local row = MySQL.single.await('SELECT * FROM `player_vehicles` WHERE TRIM(`plate`) = ?', { trim(plate) })
    return row and normalize(row) or nil
end

P7H.Vehicles.IsOwner = function(uniqueId, plate)
    local owner = MySQL.scalar.await('SELECT `citizenid` FROM `player_vehicles` WHERE TRIM(`plate`) = ?', { trim(plate) })
    return owner == uniqueId
end

P7H.Vehicles.SetStored = function(plate, garageId, props)
    if props then
        MySQL.update.await(
            'UPDATE `player_vehicles` SET `state` = 1, `garage` = ?, `mods` = ?, `fuel` = ?, `engine` = ?, `body` = ? WHERE TRIM(`plate`) = ?',
            {
                garageId,
                json.encode(props),
                math.floor(props.fuelLevel or 100),
                math.floor(props.engineHealth or 1000),
                math.floor(props.bodyHealth or 1000),
                trim(plate),
            }
        )
    else
        MySQL.update.await('UPDATE `player_vehicles` SET `state` = 1, `garage` = ? WHERE TRIM(`plate`) = ?', {
            garageId, trim(plate),
        })
    end
end

P7H.Vehicles.SetOut = function(plate)
    MySQL.update.await('UPDATE `player_vehicles` SET `state` = 0 WHERE TRIM(`plate`) = ?', { trim(plate) })
end

P7H.Vehicles.SaveProps = function(plate, props)
    MySQL.update.await('UPDATE `player_vehicles` SET `mods` = ? WHERE TRIM(`plate`) = ?', { json.encode(props), trim(plate) })
end

P7H.Vehicles.SetNickname = function(plate, nickname)
    MySQL.update.await('UPDATE `player_vehicles` SET `nickname` = ? WHERE TRIM(`plate`) = ?', { nickname, trim(plate) })
end

P7H.Vehicles.SetFavorite = function(plate, favorite)
    MySQL.update.await('UPDATE `player_vehicles` SET `favorite` = ? WHERE TRIM(`plate`) = ?', { favorite and 1 or 0, trim(plate) })
end

P7H.Vehicles.SetMileage = function(plate, mileage)
    MySQL.update.await('UPDATE `player_vehicles` SET `drivingdistance` = ? WHERE TRIM(`plate`) = ?', { mileage, trim(plate) })
end

P7H.Vehicles.TransferOwner = function(plate, targetPlayerId)
    local player = getPlayer(targetPlayerId)
    if not player then return false end

    local affected = MySQL.update.await(
        'UPDATE `player_vehicles` SET `citizenid` = ?, `license` = ?, `nickname` = NULL, `favorite` = 0 WHERE TRIM(`plate`) = ?',
        { player.PlayerData.citizenid, player.PlayerData.license, trim(plate) }
    )
    return (affected or 0) > 0
end

P7H.Vehicles.SetImpound = function(plate, impoundData)
    if impoundData then
        MySQL.update.await('UPDATE `player_vehicles` SET `impound_data` = ?, `state` = 2 WHERE TRIM(`plate`) = ?', {
            json.encode(impoundData), trim(plate),
        })
    else
        MySQL.update.await('UPDATE `player_vehicles` SET `impound_data` = NULL, `state` = 1 WHERE TRIM(`plate`) = ?', { trim(plate) })
    end
end

P7H.Vehicles.GetImpounded = function(uniqueId, location)
    local rows
    if uniqueId then
        rows = MySQL.query.await('SELECT * FROM `player_vehicles` WHERE (`impound_data` IS NOT NULL OR `state` = 2) AND `citizenid` = ?', { uniqueId })
    else
        rows = MySQL.query.await('SELECT * FROM `player_vehicles` WHERE `impound_data` IS NOT NULL OR `state` = 2')
    end

    local vehicles = {}
    for _, row in ipairs(rows or {}) do
        local vehicle = normalize(row)
        if not location or (vehicle.impound and vehicle.impound.location == location) then
            vehicles[#vehicles + 1] = vehicle
        end
    end
    return vehicles
end

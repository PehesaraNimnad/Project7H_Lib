if (Config.Framework == 'auto' and not checkResource('ND_Core')) or (Config.Framework ~= 'auto' and Config.Framework ~= 'nd') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Framework] Loaded: ND_Core')
end

RegisterNetEvent('ND:characterLoaded', function(player)
    TriggerEvent('Project7H_Lib/server/playerLoaded', player.source)
end)

P7H.Framework = {}
P7H.Framework.Name = 'nd'

P7H.Framework.FrameworkUniqueId = function()
    return Config.FrameworkUniqueId['nd']
end

P7H.Framework.GetPlayerById = function(playerId)
    if not playerId then
        lib.print.error('Player ID is required to fetch player data.')
        return nil
    end

    local xPlayer = exports["ND_Core"]:getPlayer(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s'):format(playerId))
        return nil
    end

    return xPlayer
end

P7H.Framework.GetPlayerId = function(uniqueId)
    if not uniqueId then
        lib.print.error('Unique ID is required to fetch player ID.')
        return nil
    end

    local playerData = nil
    local players = exports["ND_Core"]:getPlayers()
    for id, data in pairs(players) do
        if data.identifier == uniqueId then
            playerData = data
            break
        end
    end

    return playerData?.source or nil
end

P7H.Framework.GetPlayerByUniqueId = function(uniqueId)
    if not uniqueId then
        lib.print.error('Unique ID is required to fetch player data.')
        return nil
    end

    local playerData = nil
    local players = exports["ND_Core"]:getPlayers()
    for id, data in pairs(players) do
        if data.identifier == uniqueId then
            playerData = data
            break
        end
    end

    if not playerData then
        lib.print.error(('No player found with Unique ID: %s'):format(uniqueId))
        return nil
    end

    return playerData
end

P7H.Framework.GetUniqueId = function(playerId, isCitizenId)
    local xPlayer = type(playerId) == 'number' and exports["ND_Core"]:getPlayer(playerId) or P7H.Framework.GetPlayerByUniqueId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return nil
    end

    return isCitizenId and xPlayer[Config.FrameworkUniqueId['nd']] or xPlayer.identifier
end

P7H.Framework.GetOwnedVehicle = function(plate)
    if not plate then return nil end

    local row = MySQL.single.await('SELECT owner, properties, plate FROM nd_vehicles WHERE plate = ?', {plate})
    if not row then return nil end

    return {
        owner = row.owner,
        props = row.properties,
        plate = row.plate,
        model = nil
    }
end

P7H.Framework.SetVehicleImpounded = function(plate, impounded)
    if not plate then return false end

    local affected = MySQL.update.await('UPDATE nd_vehicles SET stored = ? WHERE plate = ?', {impounded and 0 or 1, plate})
    return (affected or 0) > 0
end

P7H.Framework.GetPlayerJob = function(playerId)
    local xPlayer = type(playerId) == 'number' and exports["ND_Core"]:getPlayer(playerId) or P7H.Framework.GetPlayerByUniqueId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s'):format(playerId))
    end

    return {
        name = xPlayer.job or 'unemployed',
        label = xPlayer.jobInfo?.label or 'Unemployed',
        grade = xPlayer.jobInfo?.rank or 0,
        grade_name = xPlayer.jobInfo?.rankName or 'unemployed',
        grade_label = xPlayer.jobInfo?.rankName or 'Unemployed'
    }
end

P7H.Framework.GetPlayerName = function(playerId, separate)
    local xPlayer = type(playerId) == 'number' and exports["ND_Core"]:getPlayer(playerId) or P7H.Framework.GetPlayerByUniqueId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return nil
    end

    if separate then
        return xPlayer.firstname, xPlayer.lastname
    end

    return ('%s %s'):format(xPlayer.firstname, xPlayer.lastname)
end

P7H.Framework.GetPlayerDob = function(playerId)
    local xPlayer = type(playerId) == 'number' and exports["ND_Core"]:getPlayer(playerId) or P7H.Framework.GetPlayerByUniqueId(playerId)
    if not xPlayer then return nil end
    return xPlayer.dob
end

P7H.Framework.GetPlayerGender = function(playerId)
    local xPlayer = type(playerId) == 'number' and exports["ND_Core"]:getPlayer(playerId) or P7H.Framework.GetPlayerByUniqueId(playerId)
    if not xPlayer then return nil end

    local gender = xPlayer.gender
    if gender == nil then return nil end

    gender = tostring(gender):lower()
    return (gender == 'female' or gender == 'f' or gender == '1') and 'female' or 'male'
end

P7H.Framework.GetMoney = function(playerId)
    local xPlayer = type(playerId) == 'number' and exports["ND_Core"]:getPlayer(playerId) or P7H.Framework.GetPlayerByUniqueId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return nil
    end

    return {
        money = xPlayer.cash or 0,
        bank = xPlayer.bank or 0,
        black_money = 0
    }
end

lib.callback.register('Project7H_Lib/server/framework/getMoney', P7H.Framework.GetMoney)

P7H.Framework.RemoveMoney = function(playerId, account, amount)
    local xPlayer = type(playerId) == 'number' and exports["ND_Core"]:getPlayer(playerId) or P7H.Framework.GetPlayerByUniqueId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    local accounts = {
        ['money'] = 'cash',
        ['cash'] = 'cash',
        ['bank'] = 'bank',
    }

    xPlayer.deductMoney(accounts[account], amount, "")
    return true
end

P7H.Framework.AddMoney = function(playerId, account, amount)
    local xPlayer = type(playerId) == 'number' and exports["ND_Core"]:getPlayer(playerId) or P7H.Framework.GetPlayerByUniqueId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    local accounts = {
        ['money'] = 'cash',
        ['cash'] = 'cash',
        ['bank'] = 'bank',
    }
    xPlayer.addMoney(accounts[account], amount, "")
    return true
end

P7H.Framework.CheckPlayerLicense = function(playerId, license)
    local xPlayer = type(playerId) == 'number' and exports["ND_Core"]:getPlayer(playerId) or P7H.Framework.GetPlayerByUniqueId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    local licenses = xPlayer.getMetadata("licenses")
    if not licenses or type(licenses) ~= 'table' then
        lib.print.error(('Player %s does not have any licenses or metadata is not a table.'):format(playerId))
        return false
    end

    for i=1, #licenses do
        if licenses[i].type == license then
            return true
        end
    end

    return false
end

P7H.Framework.AddPlayerLicense = function(playerId, license)
    local xPlayer = type(playerId) == 'number' and exports["ND_Core"]:getPlayer(playerId) or P7H.Framework.GetPlayerByUniqueId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    player.createLicense(license, os.time() + 99999999)
    return true
end

P7H.Framework.RemovePlayerLicense = function(playerId, license)
    local xPlayer = type(playerId) == 'number' and exports["ND_Core"]:getPlayer(playerId) or P7H.Framework.GetPlayerByUniqueId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    local licenses = xPlayer.getMetadata('licenses')
    if type(licenses) ~= 'table' then
        return false
    end

    for i = #licenses, 1, -1 do
        if licenses[i].type == license then
            table.remove(licenses, i)
        end
    end

    xPlayer.setMetadata('licenses', licenses)
    return true
end

P7H.Framework.SetPlayerMetadata = function(playerId, key, value)
    local xPlayer = type(playerId) == 'number' and exports["ND_Core"]:getPlayer(playerId) or P7H.Framework.GetPlayerByUniqueId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    xPlayer.setMetadata(key, value)
    return true
end

P7H.Framework.CheckPermissions = function(playerId, requiredGroups)
    local xPlayer = type(playerId) == 'number' and exports['qbx_core']:GetPlayer(playerId) or exports['qbx_core']:GetPlayerByCitizenId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    for group, _ in pairs(requiredGroups) do
        if xPlayer.getGroup(group) then
            return true
        end
    end

    return false
end

lib.callback.register('Project7H_Lib/server/framework/checkPermissions', P7H.Framework.CheckPermissions)

while not P7H do
    Citizen.Wait(0)
end

P7H.Framework = P7H.Framework or {}

local QBX = checkResource('qbx_core')
local QB = not QBX and checkResource('qb-core') and exports['qb-core']:GetCoreObject() or nil

local function player(src)
    if QBX then return exports['qbx_core']:GetPlayer(src) end
    if QB then return QB.Functions.GetPlayer(src) end
end

P7H.Framework.IsLoaded = function(src)
    return player(src) ~= nil
end

P7H.Framework.Login = function(src, citizenid, newData)
    if QBX then return exports['qbx_core']:Login(src, citizenid, newData) end
    if QB then return QB.Player.Login(src, citizenid, newData) end
    return false
end

P7H.Framework.Logout = function(src)
    if QBX then return exports['qbx_core']:Logout(src) end
    if QB then return QB.Player.Logout(src) end
end

P7H.Framework.DeleteCharacter = function(citizenid)
    if QBX then return exports['qbx_core']:DeleteCharacter(citizenid) end
    if QB then return QB.Player.ForceDeleteCharacter(citizenid) end
end

P7H.Framework.SetBucket = function(src, bucket)
    if QBX then return exports['qbx_core']:SetPlayerBucket(src, bucket) end
    SetPlayerRoutingBucket(src, bucket)
end

P7H.Framework.GetPosition = function(src)
    local p = player(src)
    local pos = p and p.PlayerData.position
    return pos and { x = pos.x, y = pos.y, z = pos.z, w = pos.w or 0.0 } or nil
end

P7H.Framework.GetOnlinePlayers = function()
    local list = {}
    if QBX then
        for src in pairs(exports['qbx_core']:GetQBPlayers()) do list[#list + 1] = src end
    elseif QB then
        for _, src in pairs(QB.Functions.GetPlayers()) do list[#list + 1] = src end
    end
    return list
end

P7H.Framework.OnlineByCitizen = function()
    local map = {}
    for _, src in ipairs(P7H.Framework.GetOnlinePlayers()) do
        local p = player(src)
        if p and p.PlayerData then map[p.PlayerData.citizenid] = src end
    end
    return map
end

P7H.Framework.GetPermission = function(src)
    local p = player(src)
    return p and p.PlayerData.permission or nil
end

P7H.Framework.GetJobList = function()
    local list = {}
    local jobs = QBX and exports['qbx_core']:GetJobs() or (QB and QB.Shared.Jobs) or {}
    for name, job in pairs(jobs) do list[#list + 1] = { name = name, label = job.label or name } end
    table.sort(list, function(a, b) return a.label < b.label end)
    return list
end

P7H.Framework.GetGang = function(src)
    local p = player(src)
    local gang = p and p.PlayerData.gang
    if not gang or gang.name == 'none' then return nil end
    return gang.label or gang.name, gang.name
end

P7H.Framework.GetPhone = function(src)
    local p = player(src)
    local ci = p and p.PlayerData.charinfo
    return ci and ci.phone and tostring(ci.phone) or nil
end

P7H.Framework.IsAdmin = function(src)
    if QBX then
        local ok, has = pcall(function() return exports['qbx_core']:HasPermission(src, 'admin') end)
        if ok and has then return true end
    end
    return IsPlayerAceAllowed(src, 'admin') or IsPlayerAceAllowed(src, 'command')
end

local function plateKey(plate)
    return type(plate) == 'string' and plate:gsub('^%s+', ''):gsub('%s+$', ''):upper() or nil
end

P7H.Framework.GetVehicleOwner = function(plate)
    plate = plateKey(plate)
    if not plate then return nil end
    if QBX or QB then
        return MySQL.scalar.await('SELECT citizenid FROM player_vehicles WHERE TRIM(UPPER(plate)) = ? LIMIT 1', { plate })
    end
    return MySQL.scalar.await('SELECT owner FROM owned_vehicles WHERE TRIM(UPPER(plate)) = ? LIMIT 1', { plate })
end

P7H.Framework.GetPlayerVehicles = function(src)
    local id = P7H.Framework.GetUniqueId(src)
    if not id then return {} end
    local out = {}
    if QBX or QB then
        for _, r in ipairs(MySQL.query.await('SELECT plate, vehicle FROM player_vehicles WHERE citizenid = ?', { id }) or {}) do
            out[#out + 1] = { plate = plateKey(r.plate), model = r.vehicle }
        end
    else
        for _, r in ipairs(MySQL.query.await('SELECT plate, vehicle FROM owned_vehicles WHERE owner = ?', { id }) or {}) do
            local ok, props = pcall(json.decode, r.vehicle or '{}')
            out[#out + 1] = { plate = plateKey(r.plate), model = ok and props and props.model or 'vehicle' }
        end
    end
    return out
end

local function unloaded(src)
    src = tonumber(src)
    if src and src > 0 then TriggerEvent('Project7H_Lib/server/playerUnloaded', src) end
end
AddEventHandler('QBCore:Server:OnPlayerUnload', unloaded)
AddEventHandler('esx:playerLogout', unloaded)

P7H.Framework.GetPlayerMetadata = function(src, key)
    local p = P7H.Framework.GetPlayerObjectByCitizen(src)
    local meta = p and p.PlayerData and p.PlayerData.metadata
    if not meta then return nil end
    if key then return meta[key] end
    return meta
end

P7H.Framework.GetPlayerObject = function(src)
    return player(tonumber(src))
end

P7H.Framework.GetOfflinePlayerObject = function(citizenid)
    if not citizenid then return nil end
    if QBX then
        local ok, p = pcall(function() return exports['qbx_core']:GetOfflinePlayer(citizenid) end)
        return ok and p or nil
    end
    if QB then return QB.Functions.GetOfflinePlayerByCitizenId(citizenid) end
end

---Every character with this job, online or not: { { citizenid, grade } }
P7H.Framework.GetJobMembers = function(jobName)
    if QBX then
        local ok, list = pcall(function() return exports['qbx_core']:GetGroupMembers(jobName, 'job') end)
        if ok and type(list) == 'table' then return list end
    end
    local out = {}
    for _, row in ipairs(MySQL.query.await("SELECT citizenid, JSON_EXTRACT(job, '$.grade.level') AS grade FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(job, '$.name')) = ?", { jobName }) or {}) do
        out[#out + 1] = { citizenid = row.citizenid, grade = tonumber(row.grade) or 0 }
    end
    return out
end

local function online(src)
    if type(src) == 'number' or tonumber(src) then return player(tonumber(src)) end
    if QBX then return exports['qbx_core']:GetPlayerByCitizenId(src) end
    if QB then return QB.Functions.GetPlayerByCitizenId(src) end
end

---Online player by server id or citizenid, else the offline character.
P7H.Framework.GetPlayerObjectByCitizen = function(idOrCitizen)
    if idOrCitizen == nil then return nil end
    return online(idOrCitizen) or (type(idOrCitizen) == 'string' and not tonumber(idOrCitizen) and P7H.Framework.GetOfflinePlayerObject(idOrCitizen)) or nil
end

P7H.Framework.GetPlayerDataOf = function(idOrCitizen)
    local p = P7H.Framework.GetPlayerObjectByCitizen(idOrCitizen)
    return p and p.PlayerData or nil
end

P7H.Framework.GetPlayerObjects = function()
    local out = {}
    for _, src in ipairs(P7H.Framework.GetOnlinePlayers()) do out[src] = player(src) end
    return out
end

---The framework job table as is (grade = { level, name, isboss }, payment, onduty ...).
P7H.Framework.GetRawJob = function(src)
    local p = player(tonumber(src))
    return p and p.PlayerData and p.PlayerData.job or nil
end

P7H.Framework.GetCharInfo = function(idOrCitizen, key)
    local data = P7H.Framework.GetPlayerDataOf(idOrCitizen)
    local ci = data and data.charinfo
    if not ci then return nil end
    if key then return ci[key] end
    return ci
end

---"First Last" of a character, online or offline.
P7H.Framework.GetCharacterName = function(idOrCitizen)
    local ci = P7H.Framework.GetCharInfo(idOrCitizen)
    if not ci then return 'Unknown Person' end
    return ('%s %s'):format(ci.firstname or '', ci.lastname or '')
end

P7H.Framework.GetJobGrade = function(jobName, grade)
    local job = P7H.Framework.GetJobs()[jobName]
    local g = job and job.grades
    if not g then return nil end
    return g[grade] or g[tonumber(grade)] or g[tostring(grade)]
end

P7H.Framework.CountOnDuty = function(jobName, byType)
    local n = 0
    for _, src in ipairs(P7H.Framework.GetOnlinePlayers()) do
        local job = P7H.Framework.GetPlayerJob(src)
        if job and job.onduty and (byType and job.type or job.name) == jobName then n = n + 1 end
    end
    return n
end

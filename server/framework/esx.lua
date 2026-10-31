if (Config.Framework == 'auto' and not checkResource('es_extended')) or (Config.Framework ~= 'auto' and Config.Framework ~= 'esx') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Framework] Loaded: ESX')
end

ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function(playerId)
    if type(playerId) == 'table' then
        playerId = playerId.source or (playerId.PlayerData and playerId.PlayerData.source)
    end
    playerId = tonumber(playerId) or tonumber(source)
    if not playerId or playerId <= 0 then return end
    TriggerEvent('Project7H_Lib/server/playerLoaded', playerId)
end)

P7H.Framework = {}
P7H.Framework.Name = 'esx'

P7H.Framework.SetOfflineJob = function(uniqueId, jobName, jobGrade)
    local result = MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {
        jobName,
        jobGrade,
        uniqueId
    })
    return result > 0
end

P7H.Framework.SetJob = function(playerId, jobName, jobGrade)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return false
    end

    xPlayer.setJob(jobName, jobGrade)
    return true
end

P7H.Framework.CheckJobDuty = function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return false
    end

    if GetResourceState('piotreq_jobcore') == 'started' then
        return exports['piotreq_jobcore']:isPlayerOnDuty(xPlayer.identifier)
    end

    return xPlayer.job?.onDuty or false
end

P7H.Framework.SetJobDuty = function(playerId, onDuty)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return false
    end

    if GetResourceState('piotreq_jobcore') == 'started' then
        exports['piotreq_jobcore']:SwitchDuty(playerId, {duty = onDuty and 1 or 0})
        return true
    end

    xPlayer.setJob(xPlayer.job.name, xPlayer.job.grade, onDuty)
    return true
end

P7H.Framework.FrameworkUniqueId = function()
    return Config.FrameworkUniqueId['esx']
end

P7H.Framework.GetJobLabels = function()
    local jobLabels = {}
    local jobs = MySQL.query.await('SELECT * FROM jobs')
    for k, v in pairs(jobs) do
        if not jobLabels[v.name] then
            jobLabels[v.name] = v.label
        end
    end
    return jobLabels
end

P7H.Framework.GetJobs = function()
    local jobsData = {}
    local job_grades = MySQL.query.await('SELECT * FROM job_grades')
    for k, v in pairs(job_grades) do
        if not jobsData[v.job_name] then
            jobsData[v.job_name] = {}
        end
        jobsData[v.job_name][v.grade] = { name = v.name, label = v.label, grade = v.grade, job_name = v.job_name }
    end
    return jobsData
end

P7H.Framework.GetPlayerById = function(playerId)
    if not playerId then
        if Config.Debug then
            lib.print.error('Player ID is required to fetch player data.')
        end
        return nil
    end

    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return nil
    end

    return xPlayer
end

P7H.Framework.GetPlayerId = function(uniqueId)
    if not uniqueId then
        if Config.Debug then
            lib.print.error('Unique ID is required to fetch player ID.')
        end
        return nil
    end

    local xPlayer = ESX.GetPlayerFromIdentifier(uniqueId)
    if not xPlayer then
        return nil
    end

    return xPlayer.source
end

P7H.Framework.GetPlayerByUniqueId = function(uniqueId)
    if not uniqueId then
        if Config.Debug then
            lib.print.error('Unique ID is required to fetch player data.')
        end
        return nil
    end

    local xPlayer = ESX.GetPlayerFromIdentifier(uniqueId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with Unique ID: %s\nInvoker: %s'):format(uniqueId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return nil
    end

    return xPlayer
end

P7H.Framework.GetOfflinePlayerByCitizenId = function(citizenId)
    return MySQL.single.await('SELECT * FROM users WHERE '..Config.FrameworkUniqueId['esx']..' = ?', {citizenId})
end

P7H.Framework.GetOfflinePlayerByUniqueId = function(identifier)
    return MySQL.single.await('SELECT * FROM users WHERE identifier = ?', {identifier})
end

P7H.Framework.GetUniqueId = function(playerId, isCitizenId)
    local xPlayer = type(playerId) == 'number' and ESX.GetPlayerFromId(playerId) or ESX.GetPlayerFromIdentifier(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return nil
    end

    if isCitizenId then
        local citizenId = xPlayer[Config.FrameworkUniqueId['esx']]
        if not citizenId then
            local row = MySQL.single.await('SELECT '..Config.FrameworkUniqueId['esx']..' FROM users WHERE identifier = ?', {xPlayer.identifier})
            if row and row[Config.FrameworkUniqueId['esx']] then
                return row[Config.FrameworkUniqueId['esx']]
            end
        else
            return citizenId
        end
    end

    return xPlayer.identifier
end

P7H.Framework.GetVehicleByPlate = function(plate)
    local result = MySQL.single.await('SELECT * FROM owned_vehicles WHERE plate = ?', {plate})
    return result
end

P7H.Framework.GetOwnedVehicle = function(plate)
    if not plate then return nil end

    local row = MySQL.single.await('SELECT owner, vehicle, plate FROM owned_vehicles WHERE plate = ?', {plate})
    if not row then return nil end

    return {
        owner = row.owner,
        props = row.vehicle,
        plate = row.plate,
        model = nil
    }
end

P7H.Framework.SetVehicleImpounded = function(plate, impounded)
    if not plate then return false end

    local affected = MySQL.update.await('UPDATE owned_vehicles SET stored = ? WHERE plate = ?', {impounded and 0 or 1, plate})
    return (affected or 0) > 0
end

P7H.Framework.GetPlayerJob = function(playerId)
    local xPlayer = type(playerId) == 'number' and ESX.GetPlayerFromId(playerId) or ESX.GetPlayerFromIdentifier(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s'):format(playerId))
        end
        return nil
    end

    return {
        name = xPlayer.job?.name or 'unemployed',
        label = xPlayer.job?.label or 'Unemployed',
        grade = xPlayer.job?.grade or 0,
        grade_name = xPlayer.job?.grade_name or 'unemployed',
        grade_label = xPlayer.job?.grade_label or 'Unemployed',
        isboss = xPlayer.job?.grade_name == 'boss'
    }
end

local identityCache = {}
local function getUsersRow(identifier)
    local cached = identityCache[identifier]
    if not cached then
        local row = MySQL.single.await('SELECT firstname, lastname, dateofbirth, sex FROM users WHERE identifier = ?', { identifier })
        cached = row or {}
        identityCache[identifier] = cached
    end
    return cached
end

local function resolveIdentity(xPlayer)
    local firstName = xPlayer.get and (xPlayer.get('firstName') or xPlayer.get('firstname'))
    local lastName  = xPlayer.get and (xPlayer.get('lastName') or xPlayer.get('lastname'))

    local vars = xPlayer.variables
    if vars then
        firstName = firstName or vars.firstName or vars.firstname
        lastName  = lastName or vars.lastName or vars.lastname
    end

    if firstName and lastName then return firstName, lastName end

    local row = getUsersRow(xPlayer.identifier)
    return firstName or row.firstname, lastName or row.lastname
end

P7H.Framework.GetPlayerName = function(playerId, separate)
    local xPlayer = type(playerId) == 'number' and ESX.GetPlayerFromId(playerId) or ESX.GetPlayerFromIdentifier(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return nil
    end

    local firstName, lastName = resolveIdentity(xPlayer)
    if not firstName and not lastName then

        firstName = (xPlayer.getName and xPlayer.getName()) or GetPlayerName(xPlayer.source) or 'Unknown'
        lastName = ''
    end
    firstName = firstName or ''
    lastName = lastName or ''

    if separate then
        return firstName, lastName
    end

    return (('%s %s'):format(firstName, lastName):gsub('%s+$', ''))
end

P7H.Framework.GetPlayerDob = function(playerId)
    local xPlayer = type(playerId) == 'number' and ESX.GetPlayerFromId(playerId) or ESX.GetPlayerFromIdentifier(playerId)
    if not xPlayer then return nil end

    local dob = xPlayer.get and xPlayer.get('dateofbirth')
    if dob == nil and xPlayer.variables then
        dob = xPlayer.variables.dateofbirth
    end
    if dob == nil then
        dob = getUsersRow(xPlayer.identifier).dateofbirth
    end
    return dob
end

P7H.Framework.GetPlayerGender = function(playerId)
    local xPlayer = type(playerId) == 'number' and ESX.GetPlayerFromId(playerId) or ESX.GetPlayerFromIdentifier(playerId)
    if not xPlayer then return nil end

    local sex = xPlayer.get and xPlayer.get('sex')
    if sex == nil and xPlayer.variables then
        sex = xPlayer.variables.sex
    end
    if sex == nil then
        sex = getUsersRow(xPlayer.identifier).sex
    end
    if sex == nil then return nil end

    sex = tostring(sex):lower()
    return (sex == 'f' or sex == 'female' or sex == '1') and 'female' or 'male'
end

P7H.Framework.GetMoney = function(playerId)
    local xPlayer = type(playerId) == 'number' and ESX.GetPlayerFromId(playerId) or ESX.GetPlayerFromIdentifier(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return nil
    end

    return {
        money = xPlayer.getAccount('money')?.money or 0,
        bank = xPlayer.getAccount('bank')?.money or 0,
        black_money = xPlayer.getAccount('black_money')?.money or 0
    }
end

lib.callback.register('Project7H_Lib/server/framework/getMoney', P7H.Framework.GetMoney)

P7H.Framework.RemoveMoney = function(playerId, account, amount)
    local xPlayer = type(playerId) == 'number' and ESX.GetPlayerFromId(playerId) or ESX.GetPlayerFromIdentifier(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return false
    end

    xPlayer.removeAccountMoney(account == 'cash' and 'money' or account, amount)
    return true
end

P7H.Framework.AddMoney = function(playerId, account, amount)
    local xPlayer = type(playerId) == 'number' and ESX.GetPlayerFromId(playerId) or ESX.GetPlayerFromIdentifier(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    xPlayer.addAccountMoney(account == 'cash' and 'money' or account, amount)
    return true
end

P7H.Framework.CheckPlayerLicense = function(playerId, license)
    local xPlayer = type(playerId) == 'number' and ESX.GetPlayerFromId(playerId) or ESX.GetPlayerFromIdentifier(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    local row = MySQL.single.await('SELECT * FROM user_licenses WHERE owner = ? and type = ?', {xPlayer.identifier, license})
    return row and true or false
end

P7H.Framework.AddPlayerLicense = function(playerId, license)
    local xPlayer = type(playerId) == 'number' and ESX.GetPlayerFromId(playerId) or ESX.GetPlayerFromIdentifier(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    MySQL.insert.await('INSERT INTO user_licenses (owner, type) VALUES (?, ?)', {xPlayer.identifier, license})
    return true
end

P7H.Framework.RemovePlayerLicense = function(playerId, license)
    local xPlayer = type(playerId) == 'number' and ESX.GetPlayerFromId(playerId) or ESX.GetPlayerFromIdentifier(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    MySQL.query.await('DELETE FROM user_licenses WHERE owner = ? AND type = ?', {xPlayer.identifier, license})
    return true
end

P7H.Framework.SetPlayerMetadata = function(playerId, key, value)
    local xPlayer = type(playerId) == 'number' and ESX.GetPlayerFromId(playerId) or ESX.GetPlayerFromIdentifier(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    if not xPlayer.setMeta then
        lib.print.error(('xPlayer.setMeta is not available on this ESX version\nInvoker: %s'):format(GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    xPlayer.setMeta(key, value)
    return true
end

P7H.Framework.CheckPermissions = function(playerId, requiredGroups)
    local xPlayer = type(playerId) == 'number' and ESX.GetPlayerFromId(playerId) or ESX.GetPlayerFromIdentifier(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    if requiredGroups[xPlayer.getGroup()] then
        return true
    end

    return false
end

lib.callback.register('Project7H_Lib/server/framework/checkPermissions', P7H.Framework.CheckPermissions)

P7H.Framework.RegisterItem = function(itemName, itemFunction)
    ESX.RegisterUsableItem(itemName, itemFunction)
end

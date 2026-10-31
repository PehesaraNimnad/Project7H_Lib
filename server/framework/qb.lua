if (Config.Framework == 'auto' and not checkResource('qb-core') and not checkResource('qbx_core')) or (Config.Framework ~= 'auto' and Config.Framework ~= 'qb') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Framework] Loaded: QB')
end

QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Server:PlayerLoaded', function(player)
    local playerId = player
    if type(playerId) == 'table' then
        playerId = (playerId.PlayerData and playerId.PlayerData.source) or playerId.source
    end
    playerId = tonumber(playerId) or tonumber(source)
    if not playerId or playerId <= 0 then return end
    TriggerEvent('Project7H_Lib/server/playerLoaded', playerId)
end)

P7H.Framework = {}
P7H.Framework.Name = 'qb'

P7H.Framework.SetOfflineJob = function(uniqueId, jobName, jobGrade)
    local row = MySQL.single.await('SELECT job FROM players WHERE citizenid = ?', { uniqueId })
    if not row then
        return false
    end

    row.job = json.decode(row.job)
    local newJob = {
        name = jobName,
        label = QBCore.Shared.Jobs[jobName]?.label or 'Unknown',
        onduty = row.job.onduty or false,
        type = QBCore.Shared.Jobs[jobName]?.type or 'none',
        grade = {
            name = QBCore.Shared.Jobs[jobName]?.grades[tostring(jobGrade)]?.name or 'No Grades',
            level = jobGrade,
            payment = QBCore.Shared.Jobs[jobName]?.grades[tostring(jobGrade)]?.payment or 0,
            isboss = QBCore.Shared.Jobs[jobName]?.grades[tostring(jobGrade)]?.isboss or false
        }
    }
    local result = MySQL.update.await('UPDATE players SET job = ? WHERE citizenid = ?', {
        json.encode(newJob),
        uniqueId
    })
    return result > 0
end

P7H.Framework.SetJob = function(playerId, jobName, jobGrade)
    local xPlayer = QBCore.Functions.GetPlayer(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return false
    end

    xPlayer.Functions.SetJob(jobName, jobGrade)
    return true
end

P7H.Framework.CheckJobDuty = function(playerId)
    local xPlayer = QBCore.Functions.GetPlayer(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return false
    end

    if GetResourceState('piotreq_jobcore') == 'started' then
        return exports['piotreq_jobcore']:isPlayerOnDuty(xPlayer.PlayerData.citizenid)
    end

    return xPlayer.PlayerData.job.onduty or false
end

P7H.Framework.SetJobDuty = function(playerId, onDuty)
    local xPlayer = QBCore.Functions.GetPlayer(playerId)
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

    xPlayer.Functions.SetJobDuty(onDuty)
    return true
end

P7H.Framework.FrameworkUniqueId = function()
    return Config.FrameworkUniqueId['qb']
end

P7H.Framework.GetJobLabels = function()
    local jobLabels = {}
    local jobs = QBCore.Shared.Jobs
    for k, v in pairs(jobs) do
        if not jobLabels[k] then
            jobLabels[k] = v.label
        end
    end
    return jobLabels
end

P7H.Framework.GetJobs = function()
    local jobsData = {}
    local jobs = QBCore.Shared.Jobs
    for k, v in pairs(jobs) do
        if not jobsData[k] then
            jobsData[k] = {}
        end
        for grade, gradeData in pairs(v.grades) do
            jobsData[k][tonumber(grade)] = {
                name = gradeData.isboss and 'boss' or gradeData.name,
                label = gradeData.name,
                grade = tonumber(grade),
            }
        end
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

    local xPlayer = QBCore.Functions.GetPlayer(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s'):format(playerId))
        end
        return nil
    end

    xPlayer.source = xPlayer.PlayerData.source
    xPlayer.identifier = xPlayer.PlayerData.citizenid
    return xPlayer
end

P7H.Framework.GetPlayerId = function(uniqueId)
    if not uniqueId then
        if Config.Debug then
            lib.print.error('Unique ID is required to fetch player ID.')
        end
        return nil
    end

    local xPlayer = QBCore.Functions.GetPlayerByCitizenId(uniqueId)
    if not xPlayer then
        return nil
    end

    return xPlayer.PlayerData.source
end

P7H.Framework.GetPlayerByUniqueId = function(uniqueId)
    if not uniqueId then
        if Config.Debug then
            lib.print.error('Unique ID is required to fetch player data.')
        end
        return nil
    end

    local xPlayer = QBCore.Functions.GetPlayerByCitizenId(uniqueId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with Unique ID: %s'):format(uniqueId))
        end
        return nil
    end

    xPlayer.source = xPlayer.PlayerData.source
    xPlayer.identifier = xPlayer.PlayerData.citizenid
    return xPlayer
end

P7H.Framework.GetOfflinePlayerByCitizenId = function(citizenId)
    local row = MySQL.single.await('SELECT * FROM players WHERE '..Config.FrameworkUniqueId['qb']..' = ?', {citizenId})
    if not row then
        return nil
    end

    local jobData = json.decode(row.job)
    local charInfo = json.decode(row.charinfo)
    row.job = jobData.name
    row.job_grade = jobData.grade.level
    row.firstname = charInfo.firstname
    row.lastname = charInfo.lastname
    return row
end

P7H.Framework.GetOfflinePlayerByUniqueId = function(identifier)
    local row = MySQL.single.await('SELECT * FROM players WHERE citizenid = ?', {identifier})
    if not row then
        return nil
    end

    local jobData = json.decode(row.job)
    local charInfo = json.decode(row.charinfo)
    row.job = jobData.name
    row.job_grade = jobData.grade.level
    row.firstname = charInfo.firstname
    row.lastname = charInfo.lastname
    return row
end

P7H.Framework.GetUniqueId = function(playerId)
    if not playerId then
        if Config.Debug then
            lib.print.error('Player ID is required to fetch unique ID.')
        end
        return nil
    end

    local xPlayer = type(playerId) == 'number' and QBCore.Functions.GetPlayer(playerId) or QBCore.Functions.GetPlayerByCitizenId(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return nil
    end

    return xPlayer.PlayerData.citizenid
end

P7H.Framework.GetVehicleByPlate = function(plate)
    local result = MySQL.single.await('SELECT * FROM player_vehicles WHERE plate = ?', {plate})
    return result
end

P7H.Framework.GetOwnedVehicle = function(plate)
    if not plate then return nil end

    local row = MySQL.single.await('SELECT citizenid, mods, vehicle, plate FROM player_vehicles WHERE plate = ?', {plate})
    if not row then return nil end

    return {
        owner = row.citizenid,
        props = row.mods,
        plate = row.plate,
        model = row.vehicle
    }
end

P7H.Framework.SetVehicleImpounded = function(plate, impounded)
    if not plate then return false end

    local affected = MySQL.update.await('UPDATE player_vehicles SET state = ? WHERE plate = ?', {impounded and 2 or 1, plate})
    return (affected or 0) > 0
end

P7H.Framework.GetPlayerJob = function(playerId)
    local xPlayer = type(playerId) == 'number' and QBCore.Functions.GetPlayer(playerId) or QBCore.Functions.GetPlayerByCitizenId(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s'):format(playerId))
        end
        return nil
    end

    return {
        name = xPlayer.PlayerData.job?.name or 'unemployed',
        label = xPlayer.PlayerData.job?.label or 'Unemployed',
        grade = xPlayer.PlayerData.job?.grade?.level or 0,
        grade_name = xPlayer.PlayerData.job?.grade?.name or 'unemployed',
        grade_label = xPlayer.PlayerData.job?.grade?.name or 'Unemployed',
        isboss = xPlayer.PlayerData.job?.isboss == true,
        type = xPlayer.PlayerData.job?.type,
        onduty = xPlayer.PlayerData.job?.onduty == true
    }
end

P7H.Framework.GetPlayerName = function(playerId, separate)
    local xPlayer = type(playerId) == 'number' and QBCore.Functions.GetPlayer(playerId) or QBCore.Functions.GetPlayerByCitizenId(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return nil
    end

    if separate then
        return xPlayer.PlayerData.charinfo.firstname, xPlayer.PlayerData.charinfo.lastname
    end

    return ('%s %s'):format(xPlayer.PlayerData.charinfo.firstname, xPlayer.PlayerData.charinfo.lastname)
end

P7H.Framework.GetPlayerDob = function(playerId)
    local xPlayer = type(playerId) == 'number' and QBCore.Functions.GetPlayer(playerId) or QBCore.Functions.GetPlayerByCitizenId(playerId)
    if not xPlayer then return nil end
    return xPlayer.PlayerData.charinfo.birthdate
end

P7H.Framework.GetPlayerGender = function(playerId)
    local xPlayer = type(playerId) == 'number' and QBCore.Functions.GetPlayer(playerId) or QBCore.Functions.GetPlayerByCitizenId(playerId)
    if not xPlayer then return nil end

    local gender = xPlayer.PlayerData.charinfo and xPlayer.PlayerData.charinfo.gender
    if gender == nil then return nil end

    gender = tostring(gender):lower()
    return (gender == '1' or gender == 'f' or gender == 'female') and 'female' or 'male'
end

P7H.Framework.GetMoney = function(playerId)
    local xPlayer = type(playerId) == 'number' and QBCore.Functions.GetPlayer(playerId) or QBCore.Functions.GetPlayerByCitizenId(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return nil
    end

    return {
        money = xPlayer.PlayerData.money['cash'] or 0,
        bank = xPlayer.PlayerData.money['bank'] or 0,
        black_money = P7H.Inventory.GetItemCount('markedbills') or P7H.Inventory.GetItemCount('black_money')
    }
end

lib.callback.register('Project7H_Lib/server/framework/getMoney', P7H.Framework.GetMoney)

P7H.Framework.RemoveMoney = function(playerId, account, amount)
    local xPlayer = type(playerId) == 'number' and QBCore.Functions.GetPlayer(playerId) or QBCore.Functions.GetPlayerByCitizenId(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return false
    end

    local accounts = {
        ['money'] = 'cash',
        ['cash'] = 'cash',
        ['cash'] = 'cash',
        ['bank'] = 'bank',
        ['black_money'] = 'crypto',
        ['crypto'] = 'crypto',
    }

    if not accounts[account] then
        lib.print.error(('Unknown account \'%s\' (invoker: %s)'):format(tostring(account), GetInvokingResource() or GetCurrentResourceName()))
        return false
    end
    return xPlayer.Functions.RemoveMoney(accounts[account], amount) ~= false
end

P7H.Framework.AddMoney = function(playerId, account, amount)
    local xPlayer = type(playerId) == 'number' and QBCore.Functions.GetPlayer(playerId) or QBCore.Functions.GetPlayerByCitizenId(playerId)
    if not xPlayer then
        if Config.Debug then
            lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        end
        return false
    end

    local accounts = {
        ['money'] = 'cash',
        ['cash'] = 'cash',
        ['cash'] = 'cash',
        ['bank'] = 'bank',
        ['black_money'] = 'crypto',
        ['crypto'] = 'crypto',
    }

    if not accounts[account] then
        lib.print.error(('Unknown account \'%s\' (invoker: %s)'):format(tostring(account), GetInvokingResource() or GetCurrentResourceName()))
        return false
    end
    return xPlayer.Functions.AddMoney(accounts[account], amount) ~= false
end

P7H.Framework.CheckPlayerLicense = function(playerId, license)
    local xPlayer = type(playerId) == 'number' and QBCore.Functions.GetPlayer(playerId) or QBCore.Functions.GetPlayerByCitizenId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    return xPlayer.PlayerData.metadata.licences[license] or false
end

P7H.Framework.AddPlayerLicense = function(playerId, license)
    local xPlayer = type(playerId) == 'number' and QBCore.Functions.GetPlayer(playerId) or QBCore.Functions.GetPlayerByCitizenId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    xPlayer.PlayerData.metadata.licences[license] = true
    xPlayer.Functions.SetMetaData('licences', xPlayer.PlayerData.metadata.licences)
    return true
end

P7H.Framework.RemovePlayerLicense = function(playerId, license)
    local xPlayer = type(playerId) == 'number' and QBCore.Functions.GetPlayer(playerId) or QBCore.Functions.GetPlayerByCitizenId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    xPlayer.PlayerData.metadata.licences[license] = false
    xPlayer.Functions.SetMetaData('licences', xPlayer.PlayerData.metadata.licences)
    return true
end

P7H.Framework.SetPlayerMetadata = function(playerId, key, value)
    local xPlayer = type(playerId) == 'number' and QBCore.Functions.GetPlayer(playerId) or QBCore.Functions.GetPlayerByCitizenId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    xPlayer.Functions.SetMetaData(key, value)
    return true
end

P7H.Framework.CheckPermissions = function(playerId, requiredGroups)
    local xPlayer = type(playerId) == 'number' and QBCore.Functions.GetPlayer(playerId) or QBCore.Functions.GetPlayerByCitizenId(playerId)
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    for group, _ in pairs(requiredGroups) do
        if QBCore.Functions.HasPermission(playerId, group) then
            return true
        end
    end

    return false
end

lib.callback.register('Project7H_Lib/server/framework/checkPermissions', P7H.Framework.CheckPermissions)

P7H.Framework.RegisterItem = function(itemName, itemFunction)
    QBCore.Functions.CreateUseableItem(itemName, itemFunction)
end

P7H.Framework.GetForensics = function(playerId)
    local xPlayer = type(playerId) == 'number' and QBCore.Functions.GetPlayer(playerId) or QBCore.Functions.GetPlayerByCitizenId(playerId)
    if not xPlayer then return nil end
    local meta = xPlayer.PlayerData and xPlayer.PlayerData.metadata
    if not meta then return nil end
    return {
        fingerprint = meta.fingerprint,
        bloodType = meta.bloodtype,
    }
end

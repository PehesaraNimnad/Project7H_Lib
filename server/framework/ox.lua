if (Config.Framework == 'auto' and not checkResource('ox_core')) or (Config.Framework ~= 'auto' and Config.Framework ~= 'ox') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Framework] Loaded: OX')
end

local Ox = require '@ox_core.lib.init'

RegisterNetEvent('ox:playerLoaded', function(playerId)
    TriggerEvent('Project7H_Lib/server/playerLoaded', playerId)
end)

P7H.Framework = {}
P7H.Framework.Name = 'ox'

P7H.Framework.FrameworkUniqueId = function()
    return Config.FrameworkUniqueId['ox']
end

P7H.Framework.GetPlayerById = function(playerId)
    if not playerId then
        lib.print.error('Player ID is required to fetch player data.')
        return nil
    end

    local player = Ox.GetPlayerFromFilter({ source = playerId })
    if not player then
        lib.print.error(('No player found with ID: %s'):format(playerId))
        return nil
    end

    return player
end

P7H.Framework.GetPlayerId = function(uniqueId)
    if not uniqueId then
        lib.print.error('Unique ID is required to fetch player ID.')
        return nil
    end

    local player = Ox.GetPlayerFromFilter({ identifier = uniqueId })
    if not player then
        lib.print.error(('No player found with unique ID: %s'):format(uniqueId))
        return nil
    end

    return player.source
end

P7H.Framework.GetPlayerByUniqueId = function(uniqueId)
    if not uniqueId then
        lib.print.error('Unique ID is required to fetch player data.')
        return nil
    end

    local player = Ox.GetPlayerFromFilter({ identifier = uniqueId })
    if not player then
        lib.print.error(('No player found with unique ID: %s'):format(uniqueId))
        return nil
    end

    return player
end

P7H.Framework.GetUniqueId = function(playerId, isCitizenId)
    if not playerId then
        lib.print.error('Player ID is required to fetch unique ID.')
        return nil
    end

    local player = Ox.GetPlayerFromFilter({ source = playerId })
    if not player then
        lib.print.error(('No player found with ID: %s'):format(playerId))
        return nil
    end

    return isCitizenId and player[Config.FrameworkUniqueId['ox']] or player.identifier
end

P7H.Framework.GetOwnedVehicle = function(plate)
    if not plate then return nil end

    local row = MySQL.single.await('SELECT owner, data, plate, model FROM vehicles WHERE plate = ?', {plate})
    if not row then return nil end

    return {
        owner = row.owner,
        props = row.data,
        plate = row.plate,
        model = row.model
    }
end

P7H.Framework.SetVehicleImpounded = function(plate, impounded)
    if not plate then return false end

    local affected
    if impounded then
        affected = MySQL.update.await('UPDATE vehicles SET stored = ? WHERE plate = ?', {'impound', plate})
    else

        affected = MySQL.update.await('UPDATE vehicles SET stored = NULL WHERE plate = ?', {plate})
    end
    return (affected or 0) > 0
end

P7H.Framework.GetPlayerJob = function(playerId)
    local xPlayer = type(playerId) == 'number' and Ox.GetPlayerFromFilter({ source = playerId }) or Ox.GetPlayerFromFilter({ identifier = playerId })
    if not xPlayer then
        lib.print.error(('No player found with ID: %s'):format(playerId))
    end

    local jobName = xPlayer.activeGroup
    local jobGrade = jobName and xPlayer.getGroup(jobName) or nil
    return {
        name = jobName or 'unemployed',
        label = jobName or 'Unemployed',
        grade = jobGrade or 0,
        grade_name = jobName or 'unemployed',
        grade_label = jobName or 'Unemployed'
    }
end

P7H.Framework.GetPlayerName = function(playerId, separate)
    local xPlayer = type(playerId) == 'number' and Ox.GetPlayerFromFilter({ source = playerId }) or Ox.GetPlayerFromFilter({ identifier = playerId })
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return nil
    end

    if separate then
        return xPlayer.get('firstName'), xPlayer.get('lastName')
    end

    return ('%s %s'):format(xPlayer.get('firstName'), xPlayer.get('lastName'))
end

P7H.Framework.GetPlayerDob = function(playerId)
    local xPlayer = type(playerId) == 'number' and Ox.GetPlayerFromFilter({ source = playerId }) or Ox.GetPlayerFromFilter({ identifier = playerId })
    if not xPlayer then return nil end
    return xPlayer.get('dateOfBirth')
end

P7H.Framework.GetPlayerGender = function(playerId)
    local xPlayer = type(playerId) == 'number' and Ox.GetPlayerFromFilter({ source = playerId }) or Ox.GetPlayerFromFilter({ identifier = playerId })
    if not xPlayer then return nil end

    local gender = xPlayer.get('gender')
    if gender == nil then return nil end

    gender = tostring(gender):lower()
    return (gender == 'female' or gender == 'f' or gender == '1') and 'female' or 'male'
end

P7H.Framework.GetMoney = function(playerId)
     local xPlayer = type(playerId) == 'number' and Ox.GetPlayerFromFilter({ source = playerId }) or Ox.GetPlayerFromFilter({ identifier = playerId })
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return nil
    end

    local account = xPlayer.getAccount()
    return {
        money = exports['ox_inventory']:Search(playerId, 'count', 'money') or 0,
        bank = account.balance or 0,
        black_money = 0
    }
end

lib.callback.register('Project7H_Lib/server/framework/getMoney', P7H.Framework.GetMoney)

P7H.Framework.RemoveMoney = function(playerId, account, amount)
     local xPlayer = type(playerId) == 'number' and Ox.GetPlayerFromFilter({ source = playerId }) or Ox.GetPlayerFromFilter({ identifier = playerId })
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    if account == 'black_money' then
        lib.print.error('Black money removal is not supported in OX Framework.')
        return false
    elseif account == 'money' or account == 'cash' then
        exports['ox_inventory']:RemoveItem(playerId, 'money', amount)
    elseif account == 'bank' then
        local account = xPlayer.getAccount()
        account.removeBalance({ amount = amount, message = 'No reason', overdraw = false })
    end

    return true
end

P7H.Framework.AddMoney = function(playerId, account, amount)
     local xPlayer = type(playerId) == 'number' and Ox.GetPlayerFromFilter({ source = playerId }) or Ox.GetPlayerFromFilter({ identifier = uniqueId })
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    if account == 'black_money' then
        lib.print.error('Black money add is not supported in OX Framework.')
        return false
    elseif account == 'money' or account == 'cash' then
        exports['ox_inventory']:AddItem(playerId, 'money', amount)
    elseif account == 'bank' then
        local account = xPlayer.getAccount()
        account.addBalance({ amount = amount, message = 'No reason' })
    end
    return true
end

P7H.Framework.CheckPlayerLicense = function(playerId, license)
    local xPlayer = type(playerId) == 'number' and Ox.GetPlayerFromFilter({ source = playerId }) or Ox.GetPlayerFromFilter({ identifier = uniqueId })
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    return xPlayer.getLicense(license)
end

P7H.Framework.AddPlayerLicense = function(playerId, license)
    local xPlayer = type(playerId) == 'number' and Ox.GetPlayerFromFilter({ source = playerId }) or Ox.GetPlayerFromFilter({ identifier = uniqueId })
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    xPlayer.addLicense(license)
    return true
end

P7H.Framework.RemovePlayerLicense = function(playerId, license)
    local xPlayer = type(playerId) == 'number' and Ox.GetPlayerFromFilter({ source = playerId }) or Ox.GetPlayerFromFilter({ identifier = uniqueId })
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    xPlayer.removeLicense(license)
    return true
end

P7H.Framework.SetPlayerMetadata = function(playerId, key, value)
    local xPlayer = type(playerId) == 'number' and Ox.GetPlayerFromFilter({ source = playerId }) or Ox.GetPlayerFromFilter({ identifier = uniqueId })
    if not xPlayer then
        lib.print.error(('No player found with ID: %s\nInvoker: %s'):format(playerId, GetInvokingResource() or GetCurrentResourceName()))
        return false
    end

    xPlayer.set(key, value, true)
    return true
end

P7H.Framework.CheckPermissions = function(playerId, requiredGroups)
    local xPlayer = type(playerId) == 'number' and Ox.GetPlayerFromFilter({ source = playerId }) or Ox.GetPlayerFromFilter({ identifier = uniqueId })
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

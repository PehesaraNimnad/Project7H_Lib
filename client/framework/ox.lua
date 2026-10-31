if (Config.Framework == 'auto' and not checkResource('ox_core')) or (Config.Framework ~= 'auto' and Config.Framework ~= 'ox') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Framework] Loaded: OX')
end

P7H.Framework = {}

local Ox = require '@ox_core.lib.init'

RegisterNetEvent('ox:playerLoaded', function(playerId)
    P7H.Framework.Loaded = true
end)

P7H.Framework.IsPlayerLoaded = function()
    return P7H.Framework.Loaded
end

P7H.Framework.FetchPlayerJob = function()
    local player = Ox.GetPlayer()
    local jobName, jobGrade = player.activeGroup, player.getGroup(player.activeGroup)
    return player and { name = jobName, label = jobName, grade = jobGrade } or { name = 'unemployed', label = 'Unemployed', grade = 0 }
end

P7H.Framework.GetIdentifier = function()
    local player = Ox.GetPlayer()
    if not player then
        lib.print.error('Player data is not available.')
        return nil
    end

    return player.stateId
end

P7H.Framework.GetPlayerName = function()
    local player = exports['ND_Core']:getPlayer()
    if not player then
        lib.print.error('Player data is not available.')
        return nil
    end

    return ('%s %s'):format(player.firstname, player.lastname)
end

if (Config.Framework == 'auto' and not checkResource('ND_Core')) or (Config.Framework ~= 'auto' and Config.Framework ~= 'nd') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Framework] Loaded: ND_Core')
end

P7H.Framework = {}

P7H.Framework.IsPlayerLoaded = function()
    local player = exports['ND_Core']:getPlayer()
    return player and true or false
end

P7H.Framework.FetchPlayerJob = function()
    local player = exports['ND_Core']:getPlayer()
    return player and { name = player.job, label = player.jobInfo?.label, grade = player.jobInfo?.rank } or { name = 'unemployed', label = 'Unemployed', grade = 0 }
end

P7H.Framework.GetIdentifier = function()
    local player = exports['ND_Core']:getPlayer()
    if not player then
        lib.print.error('Player data is not available.')
        return nil
    end

    return player.identifier
end

P7H.Framework.GetPlayerName = function()
    local player = exports['ND_Core']:getPlayer()
    if not player then
        lib.print.error('Player data is not available.')
        return nil
    end

    return ('%s %s'):format(player.firstname, player.lastname)
end

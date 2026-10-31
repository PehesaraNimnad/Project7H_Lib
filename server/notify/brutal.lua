if (Config.Notify == 'auto' and not checkResource('brutal_notify')) or (Config.Notify ~= 'auto' and Config.Notify ~= 'brutal') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Notify] Loaded: brutal_notify')
end

P7H.Notify = {}

P7H.Notify.ShowNotify = function(playerId, message, type)
    TriggerClientEvent('brutal_notify:SendAlert', playerId, 'Brutal Notify', message, 5000, type)
end

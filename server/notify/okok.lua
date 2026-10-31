if (Config.Notify == 'auto' and not checkResource('okokNotify')) or (Config.Notify ~= 'auto' and Config.Notify ~= 'okok') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Notify] Loaded: okok')
end

P7H.Notify = {}

P7H.Notify.ShowNotify = function(playerId, message, type)
    TriggerClientEvent('okokNotify:Alert', playerId, '', message, 5000, type)
end

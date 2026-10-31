if (Config.Notify == 'auto' and not checkResource('es_extended')) or (Config.Notify ~= 'auto' and Config.Notify ~= 'esx') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Notify] Loaded: ESX')
end

P7H.Notify = {}

P7H.Notify.ShowNotify = function(playerId, message, type)
    TriggerClientEvent('esx:showNotification', playerId, message, type)
end

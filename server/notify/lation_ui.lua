if (Config.Notify == 'auto' and not checkResource('lation_ui')) or (Config.Notify ~= 'auto' and Config.Notify ~= 'lation_ui') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Notify] Loaded: lation_ui')
end

P7H.Notify = {}

P7H.Notify.ShowNotify = function(playerId, message, type)
    TriggerClientEvent('lation_ui:notify', playerId, {
        message = message,
        type = type or 'info',
    })
end

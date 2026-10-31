if (Config.Notify == 'auto' and not checkResource('is_ui')) or (Config.Notify ~= 'auto' and Config.Notify ~= 'is_ui') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Notify] Loaded: ox_lib')
end

P7H.Notify = {}

P7H.Notify.ShowNotify = function(playerId, message, type)
    TriggerClientEvent('is_ui:Notify', playerId, message, nil, 5000, type)
end

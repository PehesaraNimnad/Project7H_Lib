if (Config.Notify == 'auto' and not checkResource('wasabi_uikit')) or (Config.Notify ~= 'auto' and Config.Notify ~= 'wasabi_uikit') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Notify] Loaded: wasabi_uikit')
end

P7H.Notify = {}

P7H.Notify.ShowNotify = function(playerId, message, type)
    TriggerClientEvent('Project7H_Lib/notify', playerId, message, type)
end

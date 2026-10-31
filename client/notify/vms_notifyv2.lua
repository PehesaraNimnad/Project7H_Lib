if (Config.Notify == 'auto' and not checkResource('vms_notifyv2')) or (Config.Notify ~= 'auto' and Config.Notify ~= 'vms_notifyv2') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Notify] Loaded: vms_notifyv2')
end

P7H.Notify = {}

P7H.Notify.ShowNotify = function(message, type)
    exports['vms_notifyv2']:Notification({
        description = message,
    })
end

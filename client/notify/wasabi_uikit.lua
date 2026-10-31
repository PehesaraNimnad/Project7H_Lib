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

P7H.Notify.ShowNotify = function(message, type)
    if type == 'inform' then
        type = 'info'
    end

    exports.wasabi_uikit:Notification({
        title = message,
        type = type,
    })
end

RegisterNetEvent('Project7H_Lib/notify', function(message, type)
    P7H.Notify.ShowNotify(message, type)
end)

if (Config.Notify == 'auto' and not checkResource('ox_lib')) or (Config.Notify ~= 'auto' and Config.Notify ~= 'ox_lib') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Notify] Loaded: ox_lib')
end

P7H.Notify = {}

P7H.Notify.ShowNotify = function(message, type)
    lib.notify({
        description = message,
        type = (type == 'info' or not type) and 'inform' or type
    })
end

if (Config.Phone == 'auto' and not checkResource('qs-smartphone-pro')) or (Config.Phone ~= 'auto' and Config.Phone ~= 'qs-smartphone-pro') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Phone] Loaded: qs-smartphone-pro')
end

P7H.Phone = {}

P7H.Phone.ToggleDisabled = function(state)
    exports['qs-smartphone-pro']:SetCanOpenPhone(not state)
end

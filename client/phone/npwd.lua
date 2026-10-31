if (Config.Phone == 'auto' and not checkResource('npwd')) or (Config.Phone ~= 'auto' and Config.Phone ~= 'npwd') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Phone] Loaded: npwd')
end

P7H.Phone = {}

P7H.Phone.ToggleDisabled = function(state)
    exports['npwd']:setPhoneDisabled(state)
end

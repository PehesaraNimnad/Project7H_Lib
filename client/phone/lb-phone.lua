if (Config.Phone == 'auto' and not checkResource('lb-phone')) or (Config.Phone ~= 'auto' and Config.Phone ~= 'lb-phone') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Phone] Loaded: lb-phone')
end

P7H.Phone = {}

P7H.Phone.ToggleDisabled = function(state)
    exports['lb-phone']:ToggleDisabled(state)
end

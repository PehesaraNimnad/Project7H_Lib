if (Config.CarKeys == 'auto' and not checkResource('wasabi_carlock')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'wasabi_carlock') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: wasabi_carlock')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports['wasabi_carlock']:GiveKey(vehiclePlate)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
    exports['wasabi_carlock']:RemoveKey(vehiclePlate)
end

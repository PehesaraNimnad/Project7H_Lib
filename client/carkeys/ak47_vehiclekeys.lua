if (Config.CarKeys == 'auto' and not checkResource('ak47_vehiclekeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'ak47_vehiclekeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: ak47_vehiclekeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports['ak47_vehiclekeys']:GiveKey(vehiclePlate, not NetworkGetEntityIsNetworked(vehicleEntity))
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate, vehicleEntity)
    exports['ak47_vehiclekeys']:RemoveKey(vehiclePlate, not NetworkGetEntityIsNetworked(vehicleEntity))
end

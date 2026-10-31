if (Config.CarKeys == 'auto' and not checkResource('Renewed-Vehiclekeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'Renewed-Vehiclekeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: Renewed-Vehiclekeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports['Renewed-Vehiclekeys']:addKey(vehiclePlate)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
    exports['Renewed-Vehiclekeys']:removeKey(vehiclePlate)
end

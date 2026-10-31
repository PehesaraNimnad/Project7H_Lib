if (Config.CarKeys == 'auto' and not checkResource('p_vehiclekeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'p_vehiclekeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: p_vehiclekeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports['p_vehiclekeys']:createKey(vehiclePlate, vehicleEntity)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate, vehicleEntity)
    exports['p_vehiclekeys']:removeKey(vehiclePlate, vehicleEntity, true)
end

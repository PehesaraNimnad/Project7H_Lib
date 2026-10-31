if (Config.CarKeys == 'auto' and not checkResource('filo_vehiclekey')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'filo_vehiclekey') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: filo_vehiclekey')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports.filo_vehiclekey:GiveKeys(vehiclePlate)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
    exports.filo_vehiclekey:RemoveKeys(vehiclePlate)
end

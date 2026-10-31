if (Config.CarKeys == 'auto' and not checkResource('brutal_carkeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'brutal_carkeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: brutal_carkeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports.brutal_keys:addVehicleKey(vehiclePlate, 'car')
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
    exports.brutal_keys:removeKey(vehiclePlate, true)
end

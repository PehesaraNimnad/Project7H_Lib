if (Config.CarKeys == 'auto' and not checkResource('jc_vehiclekeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'jc_vehiclekeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: jc_vehiclekeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports['jc_vehiclekeys']:GiveKeys(vehiclePlate)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
    exports['jc_vehiclekeys']:RemoveKeys(vehiclePlate)
end

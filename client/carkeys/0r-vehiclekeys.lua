if (Config.CarKeys == 'auto' and not checkResource('0r-vehiclekeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= '0r-vehiclekeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: 0r-vehiclekeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports['0r-vehiclekeys']:GiveKeys(vehiclePlate)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
    exports['0r-vehiclekeys']:RemoveKeys(vehiclePlate)
end

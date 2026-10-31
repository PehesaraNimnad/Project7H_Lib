if (Config.CarKeys == 'auto' and not checkResource('MrNewbVehicleKeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'MrNewbVehicleKeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: MrNewbVehicleKeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports.MrNewbVehicleKeys:GiveKeysByPlate(vehiclePlate)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
    exports.MrNewbVehicleKeys:RemoveKeysByPlate(vehiclePlate)
end

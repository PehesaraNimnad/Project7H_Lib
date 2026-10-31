if (Config.CarKeys == 'auto' and not checkResource('ic3d_vehiclekeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'ic3d_vehiclekeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: ic3d_vehiclekeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports.ic3d_vehiclekeys:ClientInventoryKeys('add', vehiclePlate)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
    exports.ic3d_vehiclekeys:ClientInventoryKeys('remove', vehiclePlate)
end

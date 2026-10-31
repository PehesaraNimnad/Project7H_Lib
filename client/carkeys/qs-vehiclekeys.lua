if (Config.CarKeys == 'auto' and not checkResource('qs-vehiclekeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'qs-vehiclekeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: qs-vehiclekeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicleEntity))
    exports['qs-vehiclekeys']:GiveKeys(vehiclePlate, model, true)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate, vehicleEntity)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicleEntity))
    exports['qs-vehiclekeys']:RemoveKeys(vehiclePlate, model)
end

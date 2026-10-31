if (Config.CarKeys == 'auto' and not checkResource('LifeSaver_KeySystem')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'LifeSaver_KeySystem') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: LifeSaver_KeySystem')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports['LifeSaver_KeySystem']:AddCarkey(vehiclePlate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicleEntity)))
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate, vehicleEntity)
    exports['LifeSaver_KeySystem']:RemoveCarkey(vehiclePlate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicleEntity)))
end

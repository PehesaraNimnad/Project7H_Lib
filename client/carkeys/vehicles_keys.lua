if (Config.CarKeys == 'auto' and not checkResource('vehicles_keys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'vehicles_keys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: vehicles_keys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    TriggerServerEvent("vehicles_keys:selfGiveVehicleKeys", vehiclePlate)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
    TriggerServerEvent("vehicles_keys:selfRemoveKeys", vehiclePlate)
end

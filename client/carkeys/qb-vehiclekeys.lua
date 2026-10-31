if (Config.CarKeys == 'auto' and not checkResource('qb-vehiclekeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'qb-vehiclekeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: qb-vehiclekeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', vehiclePlate)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)

end

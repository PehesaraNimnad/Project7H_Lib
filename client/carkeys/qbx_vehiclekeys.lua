if (Config.CarKeys == 'auto' and not checkResource('qbx_vehiclekeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'qbx_vehiclekeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: qbx_vehiclekeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    TriggerServerEvent('qbx_vehiclekeys:server:tookKeys', NetworkGetNetworkIdFromEntity(vehicleEntity))
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)

end

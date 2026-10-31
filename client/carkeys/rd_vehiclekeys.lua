if (Config.CarKeys == 'auto' and not checkResource('rd_vehiclekeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'rd_vehiclekeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: rd_vehiclekeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    TriggerServerEvent('rd_vehiclekeys:server:GiveKeys', vehiclePlate)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
    TriggerServerEvent('rd_vehiclekeys:server:RemoveKeys', vehiclePlate)
end

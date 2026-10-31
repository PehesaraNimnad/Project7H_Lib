if (Config.CarKeys == 'auto' and not checkResource('sna-vehiclekeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'sna-vehiclekeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: sna-vehiclekeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    TriggerEvent("vehiclekeys:client:SetOwner", vehiclePlate)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
        TriggerServerEvent('qb-vehiclekeys:server:RemoveKey', vehiclePlate)
end

if (Config.CarKeys == 'auto' and not checkResource('Project07_CarKeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'Project07_CarKeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    local plate = vehiclePlate or (vehicleEntity and GetVehicleNumberPlateText(vehicleEntity))
    if plate then TriggerEvent('vehiclekeys:client:SetOwner', plate) end
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
end

P7H.CarKeys.HasKey = function(vehiclePlate)
    return exports['Project07_CarKeys']:HasKey(vehiclePlate)
end

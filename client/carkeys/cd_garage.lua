if (Config.CarKeys == 'auto' and not checkResource('cd_garage')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'cd_garage') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: cd_garage')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    TriggerEvent('cd_garage:AddKeys', exports['cd_garage']:GetPlate(vehicleEntity))
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
end

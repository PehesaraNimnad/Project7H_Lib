if (Config.CarKeys == 'auto' and not checkResource('p_carkeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'p_carkeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: p_carkeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    TriggerServerEvent('p_carkeys:CreateKeys', vehiclePlate)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
    TriggerServerEvent('p_carkeys:RemoveKeys', vehiclePlate)
end

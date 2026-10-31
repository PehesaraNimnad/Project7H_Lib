if (Config.CarKeys == 'auto' and not checkResource('t1ger_keys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 't1ger_keys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: t1ger_keys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports['t1ger_keys']:GiveTemporaryKeys(vehiclePlate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicleEntity)), 'type')
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
end

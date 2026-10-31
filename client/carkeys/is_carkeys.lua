if (Config.CarKeys == 'auto' and not checkResource('is_carkeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'is_carkeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: is_carkeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports["is_vehiclekeys"]:GiveKey(vehiclePlate)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
    exports["is_vehiclekeys"]:RemoveKey(vehiclePlate)
end

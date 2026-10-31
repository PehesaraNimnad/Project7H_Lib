if (Config.CarKeys == 'auto' and not checkResource('mm_carkeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'mm_carkeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: mm_carkeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports.mm_carkeys:GiveKeyItem(vehiclePlate, vehicleEntity)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
    exports.mm_carkeys:RemoveKeyItem(vehiclePlate)
end

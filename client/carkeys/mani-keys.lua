if (Config.CarKeys == 'auto' and not checkResource('mani-keys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'mani-keys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: mani-keys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    export['mani-keys']:GiveKeyServerId(vehicleEntity, cache.serverId)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)
    export['mani-keys']:RemoveKeyServerId(vehicleEntity, cache.serverId)
end

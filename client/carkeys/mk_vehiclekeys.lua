if (Config.CarKeys == 'auto' and not checkResource('mk_vehiclekeys')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'mk_vehiclekeys') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: mk_vehiclekeys')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    if NetworkGetEntityIsNetworked(vehicleEntity) then
        exports['mk_vehiclekeys']:AddKey(vehicleEntity)
    else
        Entity(vehicleEntity).state:set('Keys', {LocalPlayer.state.mk_identifier}, true)
    end
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate, vehicleEntity)
    if NetworkGetEntityIsNetworked(vehicleEntity) then
        exports['mk_vehiclekeys']:RemoveKey(vehicleEntity)
    else
            Entity(vehicleEntity).state:set('Keys', {}, true)
    end
end

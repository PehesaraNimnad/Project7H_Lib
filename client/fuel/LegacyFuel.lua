if (Config.Fuel == 'auto' and not checkResource('LegacyFuel')) or (Config.Fuel ~= 'auto' and Config.Fuel ~= 'LegacyFuel') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Fuel] Loaded: LegacyFuel')
end

P7H.Fuel = {}

P7H.Fuel.SetFuel = function(vehicle, fuelLevel)
    exports['LegacyFuel']:SetFuel(vehicle, fuelLevel)
end

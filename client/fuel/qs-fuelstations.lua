if (Config.Fuel == 'auto' and not checkResource('qs-fuelstations')) or (Config.Fuel ~= 'auto' and Config.Fuel ~= 'qs-fuelstations') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Fuel] Loaded: qs-fuelstations')
end

P7H.Fuel = {}

P7H.Fuel.SetFuel = function(vehicle, fuelLevel)
    exports['qs-fuelstations']:SetFuel(vehicle, fuelLevel)
end

if (Config.Fuel == 'auto' and not checkResource('Renewed-Fuel')) or (Config.Fuel ~= 'auto' and Config.Fuel ~= 'Renewed-Fuel') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Fuel] Loaded: Renewed-Fuel')
end

P7H.Fuel = {}

P7H.Fuel.SetFuel = function(vehicle, fuelLevel)
    exports['Renewed-Fuel']:SetFuel(vehicle, fuelLevel)
end

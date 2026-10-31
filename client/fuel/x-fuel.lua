if (Config.Fuel == 'auto' and not checkResource('x-fuel')) or (Config.Fuel ~= 'auto' and Config.Fuel ~= 'x-fuel') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Fuel] Loaded: x-fuel')
end

P7H.Fuel = {}

P7H.Fuel.SetFuel = function(vehicle, fuelLevel)
    exports['x-fuel']:SetFuel(vehicle, fuelLevel)
end

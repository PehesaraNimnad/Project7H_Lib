if (Config.Fuel == 'auto' and not checkResource('myFuel')) or (Config.Fuel ~= 'auto' and Config.Fuel ~= 'myFuel') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Fuel] Loaded: myFuel')
end

P7H.Fuel = {}

P7H.Fuel.SetFuel = function(vehicle, fuelLevel)
    exports['myFuel']:SetFuel(vehicle, fuelLevel)
end

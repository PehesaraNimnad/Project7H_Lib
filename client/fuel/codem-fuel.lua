if (Config.Fuel == 'auto' and not checkResource('codem-fuel')) or (Config.Fuel ~= 'auto' and Config.Fuel ~= 'codem-fuel') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Fuel] Loaded: codem-fuel')
end

P7H.Fuel = {}

P7H.Fuel.SetFuel = function(vehicle, fuelLevel)
    exports['codem-fuel']:SetFuel(vehicle, fuelLevel)
end

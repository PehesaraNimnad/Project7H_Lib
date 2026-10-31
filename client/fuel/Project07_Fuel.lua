if (Config.Fuel == 'auto' and not checkResource('Project07_Fuel')) or (Config.Fuel ~= 'auto' and Config.Fuel ~= 'Project07_Fuel') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

P7H.Fuel = {}

P7H.Fuel.SetFuel = function(vehicle, fuelLevel)
    exports['Project07_Fuel']:SetFuel(vehicle, fuelLevel)
end

P7H.Fuel.GetFuel = function(vehicle)
    return exports['Project07_Fuel']:GetFuel(vehicle)
end

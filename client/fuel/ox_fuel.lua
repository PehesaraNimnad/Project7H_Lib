if (Config.Fuel == 'auto' and not checkResource('ox_fuel')) or (Config.Fuel ~= 'auto' and Config.Fuel ~= 'ox_fuel') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Fuel] Loaded: OX')
end

P7H.Fuel = {}

P7H.Fuel.SetFuel = function(vehicle, fuelLevel)
    SetVehicleFuelLevel(vehicle, fuelLevel)
    Entity(vehicle).state.fuel = fuelLevel
end

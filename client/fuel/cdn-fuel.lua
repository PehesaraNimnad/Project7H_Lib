if (Config.Fuel == 'auto' and not checkResource('cdn-fuel')) or (Config.Fuel ~= 'auto' and Config.Fuel ~= 'cdn-fuel') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Fuel] Loaded: cdn-fuel')
end

P7H.Fuel = {}

P7H.Fuel.SetFuel = function(vehicle, fuelLevel)
    exports["cdn-fuel"]:SetFuel(vehicle, fuelLevel)
end

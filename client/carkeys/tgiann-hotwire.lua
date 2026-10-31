if (Config.CarKeys == 'auto' and not checkResource('tgiann-hotwire')) or (Config.CarKeys ~= 'auto' and Config.CarKeys ~= 'tgiann-hotwire') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[CarKeys] Loaded: tgiann-hotwire')
end

P7H.CarKeys = {}

P7H.CarKeys.CreateKeys = function(vehiclePlate, vehicleEntity)
    exports["tgiann-hotwire"]:GiveKeyPlate(vehiclePlate, true)
end

P7H.CarKeys.RemoveKeys = function(vehiclePlate)

end

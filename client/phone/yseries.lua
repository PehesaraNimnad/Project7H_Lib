if (Config.Phone == 'auto' and not checkResource('yseries')) or (Config.Phone ~= 'auto' and Config.Phone ~= 'yseries') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Phone] Loaded: yseries')
end

P7H.Phone = {}

P7H.Phone.ToggleDisabled = function(state)
    exports['yseries']:ToggleDisabled(state)
end

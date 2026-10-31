if (Config.BossMenu == 'auto' and not checkResource('codem-bossmenu')) or (Config.BossMenu ~= 'auto' and Config.BossMenu ~= 'codem-bossmenu') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[BossMenu] Loaded: codem-bossmenu')
end

P7H.BossMenu = {}

P7H.BossMenu.OpenMenu = function()
    ExecuteCommand('bossmenu')
end

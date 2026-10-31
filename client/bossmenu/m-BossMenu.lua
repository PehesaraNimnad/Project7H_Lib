if (Config.BossMenu == 'auto' and not checkResource('m-BossMenu')) or (Config.BossMenu ~= 'auto' and Config.BossMenu ~= 'm-BossMenu') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[BossMenu] Loaded: m-BossMenu')
end

P7H.BossMenu = {}

P7H.BossMenu.OpenMenu = function()
    ExecuteCommand('bossmenu')
end

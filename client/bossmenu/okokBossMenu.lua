if (Config.BossMenu == 'auto' and not checkResource('okokBossMenu')) or (Config.BossMenu ~= 'auto' and Config.BossMenu ~= 'okokBossMenu') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[BossMenu] Loaded: okokBossMenu')
end

P7H.BossMenu = {}

P7H.BossMenu.OpenMenu = function()
    TriggerEvent('okokBossMenu:openBossMenu')
end

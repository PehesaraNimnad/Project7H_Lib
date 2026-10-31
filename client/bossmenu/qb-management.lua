if (Config.BossMenu == 'auto' and not checkResource('qb-management')) or (Config.BossMenu ~= 'auto' and Config.BossMenu ~= 'qb-management') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[BossMenu] Loaded: qb-management')
end

P7H.BossMenu = {}

P7H.BossMenu.OpenMenu = function()
    TriggerEvent('qb-bossmenu:client:OpenMenu')
end

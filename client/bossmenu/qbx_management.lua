if (Config.BossMenu == 'auto' and not checkResource('qbx_management')) or (Config.BossMenu ~= 'auto' and Config.BossMenu ~= 'qbx_management') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[BossMenu] Loaded: qbx_management')
end

P7H.BossMenu = {}

P7H.BossMenu.OpenMenu = function()
    exports['qbx_management']:OpenBossMenu('job')
end

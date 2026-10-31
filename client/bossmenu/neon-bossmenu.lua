if (Config.BossMenu == 'auto' and not checkResource('neon-boss')) or (Config.BossMenu ~= 'auto' and Config.BossMenu ~= 'neon-boss') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[BossMenu] Loaded: neon-boss')
end

P7H.BossMenu = {}

P7H.BossMenu.OpenMenu = function()
    local playerJob = P7H.Framework.FetchPlayerJob()
    if not playerJob or not playerJob.name then
        lib.print.error('No job found for the player')
        return
    end

    exports['neon-boss']:OpenBossMenu(playerJob.name, "society")
end

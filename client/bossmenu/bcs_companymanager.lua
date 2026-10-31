if (Config.BossMenu == 'auto' and not checkResource('bcs_companymanager')) or (Config.BossMenu ~= 'auto' and Config.BossMenu ~= 'bcs_companymanager') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[BossMenu] Loaded: bcs_companymanager')
end

P7H.BossMenu = {}

P7H.BossMenu.OpenMenu = function()
    local playerJob = P7H.Framework.FetchPlayerJob()
    if not playerJob or not playerJob.name then
        lib.print.error('No job found for the player')
        return
    end

    TriggerEvent('CompanyManager:client:OpenBossMenu', playerJob.name)
end

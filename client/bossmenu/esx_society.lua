if (Config.BossMenu == 'auto' and not checkResource('esx_society')) or (Config.BossMenu ~= 'auto' and Config.BossMenu ~= 'esx_society') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[BossMenu] Loaded: esx_society')
end

P7H.BossMenu = {}

P7H.BossMenu.OpenMenu = function()
    local playerJob = P7H.Framework.FetchPlayerJob()
    if not playerJob or not playerJob.name then
        lib.print.error('No job found for the player')
        return
    end

    TriggerEvent('esx_society:openBossMenu', playerJob.name, function(data, menu)
        menu.close()
    end, {checkBal = true, withdraw = true, deposit = true, wash = true, employees = true, salary = true, grades = true})
end

if (Config.Society == 'auto' and not checkResource('bcs_companymanager')) or (Config.Society ~= 'auto' and Config.Society ~= 'bcs_companymanager') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: bcs_companymanager')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    exports['bcs_companymanager']:AddCompanyMoney(jobName, 'money', amount)
    return true
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)

    if P7H.Society.GetMoney(playerId, jobName) < amount then
        return false
    end

    exports['bcs_companymanager']:RemoveCompanyMoney(jobName, 'money', amount)
    return true
end

P7H.Society.GetMoney = function(playerId, jobName)
    return exports['bcs_companymanager']:GetCompanyMoney(jobName, 'money') or 0
end

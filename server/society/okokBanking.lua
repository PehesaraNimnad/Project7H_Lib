if (Config.Society == 'auto' and not checkResource('okokBanking')) or (Config.Society ~= 'auto' and Config.Society ~= 'okokBanking') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: okokBanking')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    exports['okokBanking']:AddMoney(jobName, amount)
    return true
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    exports['okokBanking']:RemoveMoney(jobName, amount)
    return true
end

P7H.Society.GetMoney = function(playerId, jobName)
    local money = exports['okokBanking']:GetAccount(jobName)
    if money then
        return money
    end
    return 0
end

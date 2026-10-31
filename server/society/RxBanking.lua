if (Config.Society == 'auto' and not checkResource('RxBanking')) or (Config.Society ~= 'auto' and Config.Society ~= 'RxBanking') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: RxBanking')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local result = exports['RxBanking']:AddSocietyMoney(jobName, amount)
    return result
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local result = exports['RxBanking']:RemoveSocietyMoney(jobName, amount)
    return result
end

P7H.Society.GetMoney = function(playerId, jobName)
    local data = exports['RxBanking']:GetSocietyAccount(jobName)
    if data then
        return type(data) == 'number' and data or (data.money or data.balance)
    end
    return 0
end

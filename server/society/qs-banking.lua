if (Config.Society == 'auto' and not checkResource('qs-banking')) or (Config.Society ~= 'auto' and Config.Society ~= 'qs-banking') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: qs-banking')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local result = exports['qs-banking']:AddMoney(jobName, amount)
    return result
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local result = exports['qs-banking']:RemoveMoney(jobName, amount)
    return result
end

P7H.Society.GetMoney = function(playerId, jobName)
    local money = exports['qs-banking']:GetAccountBalance(jobName)
    if money then
        return money
    end
    return 0
end

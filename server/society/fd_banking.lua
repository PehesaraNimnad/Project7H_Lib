if (Config.Society == 'auto' and not checkResource('fd_banking')) or (Config.Society ~= 'auto' and Config.Society ~= 'fd_banking') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: fd_banking')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local result = exports['fd_banking']:AddMoney(jobName, amount)
    return result
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local result = exports['fd_banking']:RemoveMoney(jobName, amount)
    return result
end

P7H.Society.GetMoney = function(playerId, jobName)
    local account = exports['fd_banking']:GetAccount(jobName)
    return account and account.account_balance or 0
end

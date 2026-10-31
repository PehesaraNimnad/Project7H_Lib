if (Config.Society == 'auto' and not checkResource('Renewed-Banking')) or (Config.Society ~= 'auto' and Config.Society ~= 'Renewed-Banking') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: Renewed-Banking')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local result = exports['Renewed-Banking']:addAccountMoney(jobName, amount)
    return result
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local result = exports['Renewed-Banking']:removeAccountMoney(jobName, amount)
    return result
end

P7H.Society.GetMoney = function(playerId, jobName)
    local money = exports['Renewed-Banking']:getAccountMoney(jobName)
    if money then
        return money
    end
    return 0
end

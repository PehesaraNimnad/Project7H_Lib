if (Config.Society == 'auto' and not checkResource('nfs-banking')) or (Config.Society ~= 'auto' and Config.Society ~= 'nfs-banking') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: nfs-banking')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local result = exports['p_banking']:addAccountMoney(jobName, amount)
    return result
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local result = exports['p_banking']:removeAccountMoney(jobName, amount)
    return result
end

P7H.Society.GetMoney = function(playerId, jobName)
    local money = exports['p_banking']:getAccountMoney(jobName)
    if money then
        return money
    end
    return 0
end

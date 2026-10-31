if (Config.Society == 'auto' and not checkResource('wasabi_banking')) or (Config.Society ~= 'auto' and Config.Society ~= 'wasabi_banking') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: wasabi_banking')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local result = exports['wasabi_banking']:AddMoney('society', jobName, amount)
    return result
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local result = exports['wasabi_banking']:RemoveMoney('society', jobName, amount)
    return result
end

P7H.Society.GetMoney = function(playerId, jobName)
    local money = exports['wasabi_banking']:GetAccountBalance(jobName, 'society')
    if money then
        return money
    end
    return 0
end

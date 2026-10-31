if (Config.Society == 'auto' and not checkResource('kartik-banking')) or (Config.Society ~= 'auto' and Config.Society ~= 'kartik-banking') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: kartik-banking')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local result = exports['kartik-banking']:AddAccountMoney(jobName, amount)
    return result
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local result = exports['kartik-banking']:RemoveAccountMoney(jobName, amount)
    return result
end

P7H.Society.GetMoney = function(playerId, jobName)
    local money = exports['kartik-banking']:GetAccountMoney(jobName)
    if money then
        return money
    end
    return 0
end

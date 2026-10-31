if (Config.Society == 'auto' and not checkResource('bablo-banking')) or (Config.Society ~= 'auto' and Config.Society ~= 'bablo-banking') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: bablo-banking')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local result = exports['bablo-banking']:AddSocietyMoney(jobName, amount, 'Project7H_Lib')
    return result?.success or false
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local result = exports['bablo-banking']:RemoveSocietyMoney(jobName, amount)
    return result?.success or false
end

P7H.Society.GetMoney = function(playerId, jobName)
    local balance = exports['bablo-banking']:GetSocietyBalance(jobName)
    return balance or 0
end

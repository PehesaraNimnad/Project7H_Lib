if (Config.Society == 'auto' and not checkResource('tgg-banking')) or (Config.Society ~= 'auto' and Config.Society ~= 'tgg-banking') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: tgg-banking')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local result = exports['tgg-banking']:AddSocietyMoney(jobName, amount)
    return result
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local result = exports['tgg-banking']:RemoveSocietyMoney(jobName, amount)
    return result
end

P7H.Society.GetMoney = function(playerId, jobName)
    local money = exports['tgg-banking']:GetSocietyAccountMoney(jobName)
    if money then
        return money
    end
    return 0
end

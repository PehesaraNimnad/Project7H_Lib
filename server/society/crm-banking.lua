if (Config.Society == 'auto' and not checkResource('crm-banking')) or (Config.Society ~= 'auto' and Config.Society ~= 'crm-banking') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: crm-banking')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local result = exports['crm-banking']:addSocietyMoney(jobName, amount)
    return result
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local result = exports['crm-banking']:removeSocietyMoney(jobName, amount)
    return result
end

P7H.Society.GetMoney = function(playerId, jobName)
    local money = exports['crm-banking']:getSocietyMoney(jobName)
    if money then
        return money
    end
    return 0
end

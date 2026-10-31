if (Config.Society == 'auto' and not checkResource('prism_banking')) or (Config.Society ~= 'auto' and Config.Society ~= 'prism_banking') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: prism_banking')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    exports['prism_banking']:AddSocietyMoney(jobName, amount)
    return true
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    exports['prism_banking']:RemoveSocietyMoney(jobName, amount)
    return true
end

P7H.Society.GetMoney = function(playerId, jobName)
    local societyBalance = exports['prism_banking']:GetSocietyBalance(jobName)
    if societyBalance then
        return societyBalance
    end
    return 0
end

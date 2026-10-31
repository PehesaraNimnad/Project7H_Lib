if (Config.Society == 'auto' and not checkResource('neon-boss')) or (Config.Society ~= 'auto' and Config.Society ~= 'neon-boss') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: neon-boss')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local playerName = P7H.Framework.GetPlayerName(playerId)
    return exports['neon-boss']:AddSocietyMoney(jobName, playerName, amount, 'Deposit')
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local playerName = P7H.Framework.GetPlayerName(playerId)
    return exports['neon-boss']:RemoveSocietyMoney(jobName, playerName, amount, 'Withdrawal')
end

P7H.Society.GetMoney = function(playerId, jobName)
    local account = exports['neon-boss']:GetSocietyData(jobName)
    if account then
        return account.balance
    end
    return 0
end

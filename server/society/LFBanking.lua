if (Config.Society == 'auto' and not checkResource('LfBanking')) or (Config.Society ~= 'auto' and Config.Society ~= 'LfBanking') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: LfBanking')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local plyIdentifier = P7H.Framework.GetPlayerId(playerId)
    local result = exports['LfBanking']:creditAccount(
        false,
        plyIdentifier,
        amount,
        'Deposit',
        'deposit'
    )
    return result?.success or false
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local plyIdentifier = P7H.Framework.GetPlayerId(playerId)
    local result = exports['LfBanking']:debitAccount(
        false,
        plyIdentifier,
        amount,
        'Withdrawal',
        'withdraw'
    )
    return result
end

P7H.Society.GetMoney = function(playerId, jobName)
    local money = exports['LfBanking']:getAccountMoney(jobName)
    if money then
        return money
    end
    return 0
end

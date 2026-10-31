if (Config.Society == 'auto' and not checkResource('esx_addonaccount')) or (Config.Society ~= 'auto' and Config.Society ~= 'esx_addonaccount') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: esx_addonaccount')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local account = exports['esx_addonaccount']:GetSharedAccount(('society_%s'):format(jobName))
    if account then
        account.addMoney(amount)
        return true
    end
    return false
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local account = exports['esx_addonaccount']:GetSharedAccount(('society_%s'):format(jobName))
    if account then
        account.removeMoney(amount)
        return true
    end
    return false
end

P7H.Society.GetMoney = function(playerId, jobName)
    local account = exports['esx_addonaccount']:GetSharedAccount(('society_%s'):format(jobName))
    if account then
        return account.money
    end
    return 0
end

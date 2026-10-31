if (Config.Society == 'auto' and not checkResource('xnr-bossmenu')) or (Config.Society ~= 'auto' and Config.Society ~= 'xnr-bossmenu') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: xnr-bossmenu')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    return exports['xnr-bossmenu']:addMoney(jobName, amount)
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    return exports['xnr-bossmenu']:removeMoney(jobName, amount)
end

P7H.Society.GetMoney = function(playerId, jobName)
    local account = exports['xnr-bossmenu']:getSociety(jobName)
    if account then
        return account.balance
    end
    return 0
end

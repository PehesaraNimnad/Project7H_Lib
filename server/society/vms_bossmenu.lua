if (Config.Society == 'auto' and not checkResource('vms_bossmenu')) or (Config.Society ~= 'auto' and Config.Society ~= 'vms_bossmenu') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: vms_bossmenu')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local result = nil
    exports['vms_bossmenu']:addMoney(jobName, amount, function(success)
        result = success
    end)

    while result == nil do
        Citizen.Wait(1)
    end

    return result
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local result = nil
    exports['vms_bossmenu']:removeMoney(jobName, amount, function(success)
        result = success
    end)

    while result == nil do
        Citizen.Wait(1)
    end

    return result
end

P7H.Society.GetMoney = function(playerId, jobName)
    local account = exports['vms_bossmenu']:getSociety(jobName)
    if account then
        return account.balance
    end
    return 0
end

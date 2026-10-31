if (Config.Society == 'auto' and not checkResource('nass_bosmenu')) or (Config.Society ~= 'auto' and Config.Society ~= 'nass_bosmenu') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: nass_bosmenu')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    exports['nass_bossmenu']:addMoney(jobName, amount)
    return true
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local result = exports['nass_bossmenu']:removeMoney(jobName, amount)
    return result
end

P7H.Society.GetMoney = function(playerId, jobName)
    local money = exports['nass_bossmenu']:getAccount(jobName)
    if money then
        return money
    end
    return 0
end

if (Config.Society == 'auto' and not checkResource('nfs-billing')) or (Config.Society ~= 'auto' and Config.Society ~= 'nfs-billing') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: nfs-billing')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    exports['nfs-billing']:depositSociety(jobName, amount)
    return true
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    exports['nfs-billing']:withdrawSociety(jobName, amount)
    return true
end

P7H.Society.GetMoney = function(playerId, jobName)
    local money = exports['nfs-billing']:getSocietyBalance(jobName)
    if money then
        return money
    end
    return 0
end

if (Config.Society == 'auto' and not checkResource('m-BossMenu')) or (Config.Society ~= 'auto' and Config.Society ~= 'm-BossMenu') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: m-BossMenu')
end

P7H.Society = {}

P7H.Society.AddMoney = function(playerId, jobName, amount)
    local ok, result = pcall(function()
        return exports['m-BossMenu']:AddSocietyMoney(jobName, amount)
    end)
    if not ok then
        lib.print.error(('[Society] m-BossMenu AddSocietyMoney failed for %s: %s'):format(jobName, result))
        return false
    end
    return result == true
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local ok, result = pcall(function()
        return exports['m-BossMenu']:RemoveSocietyMoney(jobName, amount)
    end)
    if not ok then
        lib.print.error(('[Society] m-BossMenu RemoveSocietyMoney failed for %s: %s'):format(jobName, result))
        return false
    end
    return result == true
end

P7H.Society.GetMoney = function(playerId, jobName)
    local ok, balance = pcall(function()
        return exports['m-BossMenu']:GetSocietyBalance(jobName)
    end)
    if ok and tonumber(balance) then
        return tonumber(balance)
    end
    return 0
end

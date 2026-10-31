if (Config.Society == 'auto' and not checkResource('oxide-banking')) or (Config.Society ~= 'auto' and Config.Society ~= 'oxide-banking') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: oxide-banking')
end

P7H.Society = {}

local function ensureAccount(jobName)
    if not exports['oxide-banking']:GetAccountData(jobName) then
        exports['oxide-banking']:CreateJobAccount(jobName, 0)
    end
end

P7H.Society.AddMoney = function(playerId, jobName, amount)
    ensureAccount(jobName)
    local result = exports['oxide-banking']:AddMoney(jobName, amount, 'Project7H_Lib')
    return result
end

P7H.Society.RemoveMoney = function(playerId, jobName, amount)
    local result = exports['oxide-banking']:RemoveMoney(jobName, amount, 'Project7H_Lib')
    return result
end

P7H.Society.GetMoney = function(playerId, jobName)
    local balance = exports['oxide-banking']:GetAccountBalance(jobName)
    return balance or 0
end

if (Config.Notify == 'auto' and not checkResource('qb-core')) or (Config.Notify ~= 'auto' and Config.Notify ~= 'qbcore') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Notify] Loaded: QB')
end

P7H.Notify = {}

local QBCore = exports['qb-core']:GetCoreObject()

P7H.Notify.ShowNotify = function(message, type)
    if type == 'inform' then
        type = 'primary'
    end

    QBCore.Functions.Notify(message, type)
end

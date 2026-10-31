if (Config.Framework == 'auto' and not checkResource('es_extended')) or (Config.Framework ~= 'auto' and Config.Framework ~= 'esx') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Framework] Loaded: ESX')
end

ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    TriggerEvent('Project7H_Lib/client/setPlayerData', ESX.PlayerData)
end)

RegisterNetEvent('esx:setJob', function(job)
    ESX.PlayerData.job = job
    TriggerEvent('Project7H_Lib/client/setPlayerData', ESX.PlayerData)
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= cache.resource then return end
    ESX.PlayerData = ESX.GetPlayerData()

    Citizen.Wait(1000)
    if not ESX.IsPlayerLoaded() then
        return
    end

    TriggerEvent('Project7H_Lib/client/setPlayerData', ESX.PlayerData)
end)

local function getPlayerData()
    local playerData = ESX.GetPlayerData()
    if type(playerData) == 'table' and next(playerData) then
        ESX.PlayerData = playerData
        return playerData
    end
    return ESX.PlayerData or {}
end

P7H.Framework = {}

P7H.Framework.IsPlayerLoaded = function()
    return ESX.IsPlayerLoaded()
end

P7H.Framework.FetchPlayerJob = function()
    return getPlayerData().job or { name = 'unemployed', label = 'Unemployed', grade = 0 }
end

P7H.Framework.GetIdentifier = function()
    local identifier = getPlayerData().identifier
    if not identifier then
        lib.print.error('ESX PlayerData not loaded yet. Please wait for the playerLoaded event.')
        return nil
    end

    return identifier
end

P7H.Framework.GetPlayerName = function()
    local playerData = getPlayerData()
    return ('%s %s'):format(playerData.firstName or '', playerData.lastName or '')
end

P7H.Framework.CheckJobDuty = function()
    if GetResourceState('piotreq_jobcore') == 'started' then
        local dutyData = exports['piotreq_jobcore']:GetDutyData()
        return dutyData?.status == 1
    end

    local playerJob = P7H.Framework.FetchPlayerJob()
    if playerJob.onDuty == nil then
        return true
    end

    return playerJob.onDuty
end

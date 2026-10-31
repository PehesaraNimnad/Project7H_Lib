if (Config.Framework == 'auto' and not checkResource('qb-core')) or (Config.Framework ~= 'auto' and Config.Framework ~= 'qb') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Framework] Loaded: QB')
end

QBCore = exports['qb-core']:GetCoreObject()

local deadSetByBridge = false
local function syncDeadState(playerData)
    local meta = playerData and playerData.metadata
    if type(meta) ~= 'table' then return end

    local metaDead = (meta.isdead or meta.inlaststand) and true or false
    local state = LocalPlayer.state

    if metaDead and not state.isDead then
        state:set('isDead', true, true)
        deadSetByBridge = true
    elseif not metaDead and deadSetByBridge and state.isDead then
        state:set('isDead', false, true)
        deadSetByBridge = false
    end
end

RegisterNetEvent('QBCore:Player:SetPlayerData', function(xPlayer)
    QBCore.PlayerData = xPlayer
    syncDeadState(xPlayer)
    TriggerEvent('Project7H_Lib/client/setPlayerData', QBCore.PlayerData)
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= cache.resource then return end

    Citizen.Wait(1000)
    local playerData = QBCore.Functions.GetPlayerData()
    QBCore.PlayerData = playerData
    syncDeadState(playerData)
    TriggerEvent('Project7H_Lib/client/setPlayerData', playerData)
end)

local function getPlayerData()
    local playerData = QBCore.Functions.GetPlayerData()
    if type(playerData) == 'table' and next(playerData) then
        QBCore.PlayerData = playerData
        return playerData
    end
    return QBCore.PlayerData or {}
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local timeout = GetGameTimer() + 10000
    while not LocalPlayer.state.isLoggedIn and GetGameTimer() < timeout do
        Citizen.Wait(100)
    end
    Citizen.Wait(1000)

    local playerData = getPlayerData()
    syncDeadState(playerData)
    if Config.Debug then
        lib.print.info(('[Framework] Player loaded, sent player data (job: %s)'):format(tostring(playerData.job?.name)))
    end
    TriggerEvent('Project7H_Lib/client/setPlayerData', playerData)
end)

P7H.Framework = {}

P7H.Framework.IsPlayerLoaded = function()
    return LocalPlayer.state.isLoggedIn
end

P7H.Framework.FetchPlayerJob = function()
    local job = getPlayerData().job
    if not job then
        return { name = 'unemployed', label = 'Unemployed', grade = 0 }
    end

    return { name = job.name, label = job.label or job.name, grade = tonumber(job.grade?.level) or 0 }
end

P7H.Framework.GetIdentifier = function()
    local identifier = getPlayerData().citizenid
    if not identifier then
        lib.print.error('QB-Core PlayerData not loaded yet. Please wait for the playerLoaded event.')
        return nil
    end

    return identifier
end

P7H.Framework.GetPlayerName = function()
    local charinfo = getPlayerData().charinfo or {}
    return ('%s %s'):format(charinfo.firstname or '', charinfo.lastname or '')
end

P7H.Framework.CheckJobDuty = function()
    if GetResourceState('piotreq_jobcore') == 'started' then
        local dutyData = exports['piotreq_jobcore']:GetDutyData()
        return dutyData?.status == 1
    end

    local onDuty = getPlayerData().job?.onduty
    return onDuty == true
end

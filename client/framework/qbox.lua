if (Config.Framework == 'auto' and not checkResource('qbx_core')) or (Config.Framework ~= 'auto' and Config.Framework ~= 'qbox') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Framework] Loaded: QBOX')
end

P7H.Framework = {}

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
    syncDeadState(xPlayer)
    TriggerEvent('Project7H_Lib/client/setPlayerData', xPlayer)
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= cache.resource then return end

    local playerData = exports['qbx_core']:GetPlayerData() or {}
    if not playerData then return end

    Citizen.Wait(1000)
    TriggerEvent('Project7H_Lib/client/setPlayerData', playerData)
end)

P7H.Framework.IsPlayerLoaded = function()
    return LocalPlayer.state.isLoggedIn
end

P7H.Framework.FetchPlayerJob = function()
    local job = exports['qbx_core']:GetPlayerData()?.job
    if not job then
        return { name = 'unemployed', label = 'Unemployed', grade = 0 }
    end

    return { name = job.name, label = job.label or job.name, grade = tonumber(job.grade?.level) or 0 }
end

P7H.Framework.GetIdentifier = function()
    local playerData = exports['qbx_core']:GetPlayerData()
    local identifier = playerData?.citizenid
    if not identifier then
        lib.print.error('QB-Core PlayerData not loaded yet. Please wait for the playerLoaded event.')
        return nil
    end

    return identifier
end

P7H.Framework.GetPlayerName = function()
    local playerData = exports['qbx_core']:GetPlayerData()
    if not playerData then
        lib.print.error('Player data is not available.')
        return nil
    end

    return ('%s %s'):format(playerData?.charinfo.firstname, playerData?.charinfo.lastname)
end

P7H.Framework.CheckJobDuty = function()
    if GetResourceState('piotreq_jobcore') == 'started' then
        local dutyData = exports['piotreq_jobcore']:GetDutyData()
        return dutyData?.status == 1
    end

    local onDuty = exports['qbx_core']:GetPlayerData()?.job?.onduty
    return onDuty == true
end

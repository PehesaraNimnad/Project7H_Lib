while not P7H do
    Citizen.Wait(0)
end

P7H.Framework = P7H.Framework or {}

local function data()
    if checkResource('qbx_core') then return exports['qbx_core']:GetPlayerData() or {} end
    if checkResource('qb-core') then return exports['qb-core']:GetCoreObject().Functions.GetPlayerData() or {} end
    return {}
end

P7H.Framework.TriggerPlayerLoaded = function()
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
end

P7H.Framework.LoadedEvent = checkResource('es_extended') and 'esx:playerLoaded' or 'QBCore:Client:OnPlayerLoaded'
P7H.Framework.LoggedOutEvent = checkResource('es_extended') and 'esx:onPlayerLogout'
    or checkResource('qbx_core') and 'qbx_core:client:playerLoggedOut' or 'QBCore:Client:OnPlayerUnload'

P7H.Framework.IsJailed = function()
    local meta = data().metadata
    return meta ~= nil and (tonumber(meta.injail) or 0) > 0
end

P7H.Framework.IsDead = function()
    local meta = data().metadata
    return meta ~= nil and (meta.inlaststand or meta.isdead) == true
end

P7H.Framework.GetPlayerData = function()
    return data()
end

if (Config.Dispatch == 'auto' and not checkResource('op-dispatch')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'op-dispatch') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: op-dispatch')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)

    local jobName = type(data.job) == 'table' and data.job[1] or data.job
    TriggerEvent('Opto_dispatch:Server:SendAlert', jobName, data.title, data.code, plyCoords, false, playerId)
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

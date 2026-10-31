if (Config.Dispatch == 'auto' and not checkResource('glxs-dispatch')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'glxs-dispatch') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: glxs-dispatch')
end

P7H.Dispatch = {}

local ALERT_TYPE = 'Project7H_Lib_alert'

P7H.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)
    local coords = vec3(plyCoords.x, plyCoords.y, plyCoords.z)

    TriggerClientEvent('Project7H_Lib/client/dispatch/glxsRelay', playerId, ALERT_TYPE, coords, {
        coords = coords,
        message = ('%s - %s'):format(data.code, data.title),
    })
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

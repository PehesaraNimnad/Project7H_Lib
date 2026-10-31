if (Config.Dispatch == 'auto' and not checkResource('rcore_dispatch')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'rcore_dispatch') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: rcore_dispatch')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)
    TriggerEvent('rcore_dispatch:server:sendAlert', {
        code = data.code,
        default_priority = data.priority or 'normal',
        coords = vec3(plyCoords.x, plyCoords.y, plyCoords.z),
        job = data.job,
        text = data.title,
        type = 'alerts',
        blip_time = data.time or 10,
        blip = {
            sprite = data.blip?.sprite or 1,
            scale = data.blip?.scale or 1.1,
            colour = data.blip?.color or 1,
            text = data.title or 'No Title',
        }
    })
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

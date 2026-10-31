if (Config.Dispatch == 'auto' and not checkResource('cd_dispatch3d')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'cd_dispatch3d') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: cd_dispatch3d')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)
    TriggerClientEvent('cd_dispatch:AddNotification', -1, {
        job_table = data.job,
        coords = vec3(plyCoords.x, plyCoords.y, plyCoords.z),
        title = data.code,
        message = data.title,
        unique_id = tostring(math.random(0000000,9999999)),
        sound = 1,
        blip = {
            sprite = data.blip?.sprite or 1,
            scale = data.blip?.scale or 1.2,
            colour = data.blip?.color or 3,
            flashes = data.priority == 'high',
            text = ('%s - %s'):format(data.code, data.title),
            time = data.time,
            radius = 0,
        }
    })
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

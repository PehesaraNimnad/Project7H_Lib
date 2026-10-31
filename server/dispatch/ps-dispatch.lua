if (Config.Dispatch == 'auto' and not checkResource('ps-dispatch')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'ps-dispatch') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: ps-dispatch')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)
    TriggerEvent('ps-dispatch:server:notify', {
        message = data.title,
        codeName = 'NONE',
        code = data.code,
        icon = data.icon or 'fa-solid fa-bell',
        priority = data.priority == 'high' and 1 or 2,
        coords = vector3(plyCoords.x, plyCoords.y, plyCoords.z),
        alert = {
            radius = 0,
            sprite = data.blip?.sprite or 1,
            scale = data.blip?.scale or 1.1,
            color = data.blip?.color or 1,
            flash = data.priority == 'high',
            length = data.time or 5
        },
        length = data.time or 5,
        jobs = data.job
    })
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

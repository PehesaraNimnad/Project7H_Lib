if (Config.Dispatch == 'auto' and not checkResource('oxide-dispatch')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'oxide-dispatch') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: oxide-dispatch')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)

    local priority = 2
    if data.priority == 'high' then
        priority = 1
    elseif data.priority == 'low' then
        priority = 3
    end

    exports['oxide-dispatch']:CreateAlert({
        code = data.code,
        title = data.title,
        message = data.title,
        priority = priority,
        jobs = data.job,
        coords = vec3(plyCoords.x, plyCoords.y, plyCoords.z),
        icon = data.icon,
        blipData = {
            sprite = data.blip?.sprite or 1,
            color = data.blip?.color or 1,
            scale = data.blip?.scale or 1.0,
        },
        source_type = 'player',
        source_name = GetPlayerName(playerId),
        expireMinutes = data.time,
        street = data.street,
    })
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

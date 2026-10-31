if (Config.Dispatch == 'auto' and not checkResource('qs-dispatch')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'qs-dispatch') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: qs-dispatch')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)
    data.time = data.time or 5
    TriggerEvent('qs-dispatch:server:CreateDispatchCall', {
        job = data.job,
        callLocation = vector3(plyCoords.x, plyCoords.y, plyCoords.z),
        callCode = { code = data.code, snippet = data.code },
        message = data.title,
        flashes = data.priority == 'high',
        blip = {
            sprite = data.blip?.sprite or 1,
            scale = data.blip?.scale or 1.5,
            colour = data.blip?.color or 1,
            flashes = data.priority == 'high',
            text = data.title,
            time = data.time * 60 * 1000,
        }
    })
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

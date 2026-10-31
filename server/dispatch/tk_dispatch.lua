if (Config.Dispatch == 'auto' and not checkResource('tk_dispatch')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'tk_dispatch') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: tk-dispatch')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)
    exports['tk_dispatch']:addCall({
        title = data.title,
        code = data.code,
        priority = data.priority or 'normal',
        coords = vector3(plyCoords.x, plyCoords.y, plyCoords.z),
        showTime = 5000,
        jobs = data.job,
        blip = {
            sprite = data.blip?.sprite or 1,
            scale = data.blip?.scale or 1.1,
            color = data.blip?.color or 1,
            flash = data.priority == 'high',
            shortRange = true
        }
    })
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

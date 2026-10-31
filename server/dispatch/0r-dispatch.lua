if (Config.Dispatch == 'auto' and not checkResource('0r-dispatch')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= '0r-dispatch') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: 0r-dispatch')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)

    if data.priority == 'normal' then data.priority = 'low' end
    if data.priority == 'risk' then data.priority = 'high' end
    if data.priority ~= 'low' and data.priority ~= 'medium' and data.priority ~= 'high' then
        data.priority = 'low'
    end

    exports['0r-dispatch']:SendAlert(
        playerId,
        data.title,
        data.code,
        data.icon or "fa-dollar-sign",
        data.job or {'police'},
        data.blip?.sprite
    )
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

if (Config.Dispatch == 'auto' and not checkResource('core_dispatch')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'core_dispatch') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: core_dispatch')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)
    exports['core_dispatch']:addCall(
        data.code,
        data.title,
        {},
        {
            data.coords or plyCoords
        },
        'police',
        3000,
        data.blip?.sprite or 1,
        data.blip?.color or 3,
        false
    )
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

if (Config.Dispatch == 'auto' and not checkResource('wasabi_mdt')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'wasabi_mdt') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: wasabi_mdt')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)

    exports.wasabi_mdt:CreateDispatch({
        type = "disturbance",
        title = data.title,
        coords = vec3(plyCoords.x, plyCoords.y, plyCoords.z),
        priority = 2,
    })
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

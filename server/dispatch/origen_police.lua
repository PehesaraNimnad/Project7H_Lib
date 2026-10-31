if (Config.Dispatch == 'auto' and not checkResource('origen_police')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'origen_police') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: origen_police')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)
    if type(data.jobs) == 'table' then
        for k, v in pairs(data.jobs) do
            exports['origen_police']:SendAlert({
                coords = vec3(plyCoords.x, plyCoords.y, plyCoords.z),
                title = data.title,
                type = 'GENERAL',
                message = data.code,
                job = v,
            })
        end
    else
        exports['origen_police']:SendAlert({
            coords = vec3(plyCoords.x, plyCoords.y, plyCoords.z),
            title = data.title,
            type = 'GENERAL',
            message = data.code,
            job = data.job or 'police',
        })
    end
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

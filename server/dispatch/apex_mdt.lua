if (Config.Dispatch == 'auto' and not checkResource('apex_mdt')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'apex_mdt') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: apex_mdt')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    local coords = data.coords
    if not coords then
        local plyPed = GetPlayerPed(playerId)
        coords = GetEntityCoords(plyPed)
    end

    local mode = 'police'
    if data.job then
        local jobs = type(data.job) == 'table' and data.job or { data.job }
        for k, v in pairs(jobs) do
            local jobName = type(v) == 'string' and v or k
            if jobName == 'ambulance' or jobName == 'ems' or jobName == 'doctor' then
                mode = 'ems'
                break
            end
        end
    end

    exports['apex_mdt']:CreateCall({
        mode = mode,
        code = data.code,
        label = data.title,
        priority = data.priority or 'medium',
        desc = data.description or ('%s - %s'):format(data.code or '10-71', data.title or 'Alert'),
        location = data.street,
        coords = vec3(coords.x, coords.y, coords.z),
    })
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

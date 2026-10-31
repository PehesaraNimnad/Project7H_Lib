if (Config.Dispatch == 'auto' and not checkResource('kartik-mdt')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'kartik-mdt') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: kartik-mdt')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)
    local alertJobs = {}
    if data.job then
        if type(data.job) == 'string' then
            alertJobs[data.job] = true
        elseif type(data.job) == 'table' then
            for k, v in pairs(data.job) do
                if type(v) == 'string' then
                    alertJobs[v] = true
                elseif type(k) == 'string' and type(v) =='boolean' then
                    alertJobs[k] = v
                end
            end
        end
    end
    local dispatchData = {
        title = data.title,
        code = data.code,
        description = data.description or ('%s - %s'):format(data.code, data.title),
        sound = "dispatch",
        x = plyCoords.x,
        y = plyCoords.y,
        z = plyCoords.z,
        type = "Alert",
        blip = {
            sprite = data.blip?.sprite or 1,
            color = data.blip?.color or 1,
            scale = data.blip?.scale or 1.2,
            length = data.time
        },
        jobs = data.job and alertJobs or {['police'] = true}
    }
    TriggerEvent('kartik-mdt:server:sendDispatchNotification', dispatchData)
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

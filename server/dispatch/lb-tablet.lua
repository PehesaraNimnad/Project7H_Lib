if (Config.Dispatch == 'auto' and not checkResource('lb-tablet')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'lb-tablet') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: lb-tablet')
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

    if data.job and type(data.job) == 'table' then
        for i = 1, #data.job do
            exports["lb-tablet"]:AddDispatch({
                priority = data.priority or 'low',
                code = data.code,
                title = data.title,
                description = ('%s - %s'):format(data.code, data.title),
                location = {label = data.street or '', coords = vec2(plyCoords.x, plyCoords.y)},
                time = data.time * 60,
                job = data.job[i],
                blip = {
                    sprite = data.blip?.sprite or 1,
                    size = data.blip?.scale or 1.2,
                    color = data.blip?.color or 3,
                    shortRange = true,
                    label = data.title or 'No Title',
                    flashes = data.blip?.flashes or false,
                }
            })
        end
    else
        exports["lb-tablet"]:AddDispatch({
            priority = data.priority or 'low',
            code = data.code,
            title = data.title,
            description = ('%s - %s'):format(data.code, data.title),
            location = {label = data.street or '', coords = vec2(plyCoords.x, plyCoords.y)},
            time = data.time * 60,
            job = data.job or 'police',
            blip = {
                sprite = data.blip?.sprite or 1,
                size = data.blip?.scale or 1.2,
                color = data.blip?.color or 3,
                shortRange = true,
                label = data.title or 'No Title',
                flashes = data.blip?.flashes or false,
            }
        })
    end
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

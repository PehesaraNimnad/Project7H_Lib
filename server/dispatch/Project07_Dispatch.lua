if (Config.Dispatch == 'auto' and not checkResource('Project07_Dispatch')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'Project07_Dispatch') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: Project07_Dispatch')
end

local LEVELS = { low = 1, normal = 1, medium = 2, high = 3, critical = 3 }

P7H.Dispatch = {}

---@param playerId number
---@param data table { type? (alert type from /dispatchadmin), code, title, icon, priority ('normal'|'medium'|'high' or 1-3), job, blip, time, coords?, information? }
P7H.Dispatch.SendAlert = function(playerId, data)
    data = data or {}
    local ped = GetPlayerPed(playerId)
    local coords = data.coords or (ped and ped ~= 0 and GetEntityCoords(ped))
    if not coords then return false end
    local level = tonumber(data.priority) or LEVELS[data.priority] or 1

    if type(data.type) == 'string' then
        return exports['Project07_Dispatch']:SendAlert(data.type, {
            coords = coords, street = data.street, information = data.information or data.message, level = data.level,
        })
    end

    local jobs = type(data.job) == 'table' and data.job or { data.job or 'leo' }
    return exports['Project07_Dispatch']:ServerAlert({
        message = data.title or data.message or 'Alert',
        code = data.code or '10-80',
        codeName = data.codeName or 'custom',
        icon = data.icon or 'fas fa-bell',
        level = level,
        coords = coords,
        street = data.street,
        information = data.information,
        jobs = jobs,
        alertTime = tonumber(data.time),
        alert = {
            sprite = data.blip and data.blip.sprite or 161,
            color = data.blip and data.blip.color or 1,
            scale = data.blip and data.blip.scale or 1.0,
            length = 2, radius = 0, offset = false, flash = level == 3,
        },
    })
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

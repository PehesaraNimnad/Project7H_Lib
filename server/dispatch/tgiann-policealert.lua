if (Config.Dispatch == 'auto' and not checkResource('tgiann-policealert')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'tgiann-policealert') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: tgiann-policealert')
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

    exports["tgiann-policealert"]:Alert(src, {
        jobs = data.jobs or {'police'},
        label = data.title,
        coords = plyCoords,
        code = data.code,
        policeCount = data.maxOfficers,
        icon = data.icon,
        iconColor = '#FF0000',
        bgAnimate = false,
        gender = true,
        blip = data.blip?.sprite or 280,
})
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

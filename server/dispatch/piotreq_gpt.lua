if (Config.Dispatch == 'auto' and not checkResource('piotreq_gpt')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'piotreq_gpt') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: piotreq_gpt')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    exports['piotreq_gpt']:SendAlert(playerId, {
        title = data.title or 'No Title',
        code = data.code or 'No Code',
        icon = data.icon or 'fa-solid fa-bell',
        info = {
            {icon = 'fa-solid fa-road', isStreet = true},
        },
        blip = {
            scale = data.blip?.scale or 1.1,
            sprite = data.blip?.sprite or 1,
            category = data.blip?.category or 1,
            color = data.blip?.color or 1,
            hidden = data.blip?.hidden or false,
            priority = data.blip?.priority or 5,
            short = data.blip?.short or true,
            alpha = data.blip?.alpha or 200,
            name = data.blip?.name or "Blip Name"
        },
        type = data.priority == 'high' and 'risk' or 'normal',
        canAnswer = data.code == '911' and true or false,
        maxOfficers = data.maxOfficers or 4,
        time = data.time or 10,
        notifyTime = data.notify or 8000,
    })
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

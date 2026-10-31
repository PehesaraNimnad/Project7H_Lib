if (Config.Notify == 'auto' and not checkResource('g-notifications')) or (Config.Notify ~= 'auto' and Config.Notify ~= 'g-notifications') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Notify] Loaded: g-notifications')
end

P7H.Notify = {}

P7H.Notify.ShowNotify = function(playerId, message, type)
    if type == 'inform' then
        type = 'info'
    end
    TriggerClientEvent("g-notification:notify", playerId, {
	    title = "Notification",
	    description = message,
	    type = type or "info",
    })
end

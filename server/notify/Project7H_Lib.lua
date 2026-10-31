-- Our own notify (web/): setr p7h:notify Project7H_Lib
if Config.Notify ~= 'Project7H_Lib' then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Notify] Loaded: Project7H_Lib')
end

P7H.Notify = {}

P7H.Notify.ShowNotify = function(playerId, message, type)
    TriggerClientEvent('Project7H_Lib:ui:notify', playerId, { description = message, type = type })
end

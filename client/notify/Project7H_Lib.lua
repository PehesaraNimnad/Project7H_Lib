-- Our own notify (web/): setr p7h:notify Project7H_Lib
if Config.Notify ~= 'Project7H_Lib' then
    return
end

while not P7H or not P7H.UI do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Notify] Loaded: Project7H_Lib')
end

P7H.Notify = {}

P7H.Notify.ShowNotify = function(message, type)
    P7H.UI.Notify({ description = message, type = type })
end

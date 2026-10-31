-- Our own text UI (web/): setr p7h:textUI Project7H_Lib
if Config.TextUI ~= 'Project7H_Lib' then
    return
end

while not P7H or not P7H.UI do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[TextUI] Loaded: Project7H_Lib')
end

P7H.TextUI = {}

P7H.TextUI.Show = function(text, options)
    P7H.UI.ShowTextUI(text, options)
end

P7H.TextUI.Hide = function()
    P7H.UI.HideTextUI()
end

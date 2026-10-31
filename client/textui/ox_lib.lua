if (Config.TextUI == 'auto' and not checkResource('ox_lib')) or (Config.TextUI ~= 'auto' and Config.TextUI ~= 'ox_lib') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[TextUI] Loaded: ox_lib')
end

P7H.TextUI = {}

P7H.TextUI.Show = function(text, options)
    lib.showTextUI(text, options)
end

P7H.TextUI.Hide = function()
    lib.hideTextUI()
end

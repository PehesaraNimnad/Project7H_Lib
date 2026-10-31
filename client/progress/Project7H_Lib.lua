-- Our own progress bar / circle (web/): setr p7h:progressBar Project7H_Lib
if Config.ProgressBar ~= 'Project7H_Lib' then
    return
end

while not P7H or not P7H.UI do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Progress] Loaded: Project7H_Lib')
end

P7H.Progress = {}

local function defaults(data)
    data = data or {}
    if data.canCancel == nil then data.canCancel = true end
    if data.useWhileDead == nil then data.useWhileDead = false end
    data.duration = data.duration or 5000
    data.label = data.label or 'Processing...'
    data.disable = data.disable or { move = true, car = true, combat = true }
    return data
end

P7H.Progress.Start = function(data)
    return P7H.UI._runProgress(defaults(data), false)
end

P7H.Progress.StartCircle = function(data)
    return P7H.UI._runProgress(defaults(data), true)
end

P7H.Progress.IsActive = function()
    return P7H.UI.ProgressActive()
end

P7H.Progress.Cancel = function()
    P7H.UI.CancelProgress()
end

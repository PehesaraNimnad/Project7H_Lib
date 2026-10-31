if (Config.ProgressBar == 'auto' and not checkResource('lation_ui')) or (Config.ProgressBar ~= 'auto' and Config.ProgressBar ~= 'lation_ui') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Progress] Loaded: lation_ui')
end

P7H.Progress = {}

P7H.Progress.Start = function(data)
    return exports.lation_ui:progressBar({
        label = data.label or 'Processing...',
        duration = data.duration or 5000,
        useWhileDead = data.useWhileDead,
        canCancel = data.canCancel,
        anim = data.anim or nil,
        prop = data.prop or nil,
        disable = data.disable or { move = true, car = true, combat = true }
    })
end

P7H.Progress.StartCircle = function(data)
    return exports.lation_ui:progressBar({
        label = data.label or 'Processing...',
        duration = data.duration or 5000,
        useWhileDead = data.useWhileDead,
        canCancel = data.canCancel,
        anim = data.anim or nil,
        prop = data.prop or nil,
        disable = data.disable or { move = true, car = true, combat = true }
    })
end

P7H.Progress.IsActive = function()
    return exports.lation_ui:progressActive()
end

P7H.Progress.Cancel = function()
    exports.lation_ui:cancelProgress()
end

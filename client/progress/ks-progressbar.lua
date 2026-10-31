if (Config.ProgressBar == 'auto' and not checkResource('ks-progressbar')) or (Config.ProgressBar ~= 'auto' and Config.ProgressBar ~= 'ks-progressbar') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Progress] Loaded: ks-progressbar')
end

P7H.Progress = {}

P7H.Progress.Start = function(data)
    if data.canCancel == nil then
        data.canCancel = true
    end

    if data.useWhileDead == nil then
        data.useWhileDead = false
    end

    return lib.progressBar({
        duration = data.duration or 5000,
        label = data.label or 'Processing...',
        useWhileDead = data.useWhileDead,
        canCancel = data.canCancel,
        anim = data.anim or nil,
        prop = data.prop or nil,
        disable = data.disable or {move = true, car = true, combat = true}
    })
end

P7H.Progress.StartCircle = function(data)
    if data.canCancel == nil then
        data.canCancel = true
    end

    if data.useWhileDead == nil then
        data.useWhileDead = false
    end

    return lib.progressCircle({
        duration = data.duration or 5000,
        position = data.position or 'center',
        label = data.label or 'Processing...',
        useWhileDead = data.useWhileDead,
        canCancel = data.canCancel,
        anim = data.anim or nil,
        prop = data.prop or nil,
        disable = data.disable or {move = true, car = true, combat = true}
    })
end

P7H.Progress.IsActive = function()
    return lib.progressActive()
end

P7H.Progress.Cancel = function()
    lib.cancelProgress()
end

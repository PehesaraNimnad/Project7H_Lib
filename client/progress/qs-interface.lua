if (Config.ProgressBar == 'auto' and not checkResource('qs-interface')) or (Config.ProgressBar ~= 'auto' and Config.ProgressBar ~= 'qs-interface') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Progress] Loaded: qs-interface')
end

P7H.Progress = {}
local progressActive = false

P7H.Progress.Start = function(data)
    if data.canCancel == nil then
        data.canCancel = true
    end

    if data.useWhileDead == nil then
        data.useWhileDead = false
    end

    progressActive = true
    local success = exports['qs-interface']:ProgressBar({
        duration = data.duration or 5000,
        label = data.label or 'Processing...',
        useWhileDead = data.useWhileDead,
        canCancel = data.canCancel,
        anim = data.anim or nil,
        prop = data.prop or nil,
        disable = data.disable or {move = true, car = true, combat = true}
    })
    progressActive = false
    return success and true or false
end

P7H.Progress.StartCircle = function(data)
    if data.canCancel == nil then
        data.canCancel = true
    end

    if data.useWhileDead == nil then
        data.useWhileDead = false
    end

    progressActive = true
    local success = exports['qs-interface']:ProgressBar({
        duration = data.duration or 5000,
        label = data.label or 'Processing...',
        useWhileDead = data.useWhileDead,
        canCancel = data.canCancel,
        anim = data.anim or nil,
        prop = data.prop or nil,
        disable = data.disable or {move = true, car = true, combat = true}
    })
    progressActive = false
    return success and true or false
end

P7H.Progress.IsActive = function()
    return progressActive
end

P7H.Progress.Cancel = function()

end

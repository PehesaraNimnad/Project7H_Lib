if (Config.ProgressBar == 'auto' and not checkResource('esx_progressbar')) or (Config.ProgressBar ~= 'auto' and Config.ProgressBar ~= 'esx') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Notify] Loaded: ESX')
end

P7H.Progress = {}

P7H.Progress.Start = function(data)
    if P7H.Progress.Active then
        return false
    end

    local p = promise.new()
    P7H.Progress.Active = true
    exports['esx_progressbar']:Progressbar(data.label or 'Processing...', data.duration or 5000, {
        FreezePlayer = data.disable ~= nil,
        animation = data.anim and {
            type = "anim",
            dict = data.anim?.dict,
            lib = data.anim?.clip
        } or nil,
        onFinish = function()
        p:resolve(true)
    end, onCancel = function()
        p:resolve(false)
    end})

    P7H.Progress.Active = false
    return Citizen.Await(p)
end

P7H.Progress.StartCircle = function(data)
    if P7H.Progress.Active then
        return false
    end

    local p = promise.new()
    P7H.Progress.Active = true
    exports['esx_progressbar']:Progressbar(data.label or 'Processing...', data.duration or 5000, {
        FreezePlayer = data.disable ~= nil,
        animation = data.anim and {
            type = "anim",
            dict = data.anim?.dict,
            lib = data.anim?.clip
        } or nil,
        onFinish = function()
        p:resolve(true)
    end, onCancel = function()
        p:resolve(false)
    end})

    P7H.Progress.Active = false
    return Citizen.Await(p)
end

P7H.Progress.IsActive = function()
    return P7H.Progress.Active
end

P7H.Progress.Cancel = function()
    exports['esx_progressbar']:CancelProgressbar()
end

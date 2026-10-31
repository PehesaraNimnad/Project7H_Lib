if (Config.ProgressBar == 'auto' and not checkResource('progressbar')) or (Config.ProgressBar ~= 'auto' and Config.ProgressBar ~= 'qb') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Progress] Loaded: qb')
end

P7H.Progress = {}

P7H.Progress.Start = function(data)
    local p = promise.new()
    local name = tostring(math.random(1111111111, 99999999999))
    local disableControls = {disableMovement = true, disableCarMovement = true, disableCombat = true}
    if data.disable then
        disableControls = {
            disableMovement = data.disable?.move ~= nil and data.disable?.move or true,
            disableCarMovement = data.disable?.car ~= nil and data.disable?.car or true,
            disableCombat = data.disable?.combat ~= nil and data.disable?.combat or true
        }
    end
    exports['progressbar']:Progress({
        name = name:lower(),
        duration = data.duration or 5000,
        label = data.label or 'Processing...',
        useWhileDead = data.useWhileDead ~= nil and data.useWhileDead or false,
        canCancel = data.canCancel ~= nil and data.canCancel or true,
        controlDisables = disableControls,
        animation = data.anim and {animDict = data.anim?.dict, anim = data.anim?.clip, flags = data.anim?.flag} or nil,
        prop = data.prop and {model = data.prop?.model, bone = data.prop?.bone, coords = data.prop?.pos, rotation = data.prop?.rot} or nil,
    }, function(cancelled)
        p:resolve(not cancelled)
    end)

    return Citizen.Await(p)
end

P7H.Progress.StartCircle = function(data)
    local p = promise.new()
    local name = tostring(math.random(1111111111, 99999999999))
    local disableControls = {disableMovement = true, disableCarMovement = true, disableCombat = true}
    if data.disable then
        disableControls = {
            disableMovement = data.disable?.move or true,
            disableCarMovement = data.disable?.car or true,
            disableCombat = data.disable?.combat or true
        }
    end
    exports['progressbar']:Progress({
        name = name:lower(),
        duration = data.duration or 5000,
        label = data.label or 'Processing...',
        useWhileDead = data.useWhileDead ~= nil and data.useWhileDead or false,
        canCancel = data.canCancel ~= nil and data.canCancel or true,
        controlDisables = disableControls,
        animation = data.anim and {animDict = data.anim?.dict, anim = data.anim?.clip, flags = data.anim?.flag} or nil,
        prop = data.prop and {model = data.prop?.model, bone = data.prop?.bone, coords = data.prop?.pos, rot = data.prop?.rot} or nil,
    }, function(cancelled)
        p:resolve(not cancelled)
    end)

    return Citizen.Await(p)
end

P7H.Progress.IsActive = function()
    return exports['progressbar']:isDoingSomething()
end

P7H.Progress.Cancel = function()
    TriggerEvent('progressbar:client:cancel')
end

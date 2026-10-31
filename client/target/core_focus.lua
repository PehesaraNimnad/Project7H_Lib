if (Config.Target == 'auto' and checkResource('core_focus')) or (Config.Target ~= 'auto' and Config.Target ~= 'core_focus') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Target] Loaded: core_focus')
end

P7H.Target = {}

P7H.Target.ToggleTarget = function(state)
    exports['qb-target']:AllowTargeting(state)
end

P7H.Target.AddGlobal = function(options)
    return 'textUI'
end

P7H.Target.RemoveGlobal = function(optionNames)

end

P7H.Target.AddPlayer = function(options)
    for i = 1, #options do
        if options[i].onSelect then
            options[i].action = options[i].onSelect
        end
        if options[i].groups then
            local jobs = {}
            for k, v in pairs(options[i].groups) do
                if type(v) == 'string' then
                    jobs[v] = 0
                else
                    jobs = options[i].groups
                    break
                end
            end
            options[i].job = jobs
        end
        if options[i].items then
            options[i].item = options[i].items
        end
    end
    exports['core_focus']:AddGlobalPlayer({
        options = options,
        distance = options[1]?.distance or 2.0,
    })
end

P7H.Target.RemovePlayer = function(optionNames)
    exports['core_focus']:RemoveGlobalPlayer(optionNames)
end

P7H.Target.AddVehicle = function(options)
    for i = 1, #options do
        if options[i].onSelect then
            options[i].action = options[i].onSelect
        end
        if options[i].groups then
            local jobs = {}
            for k, v in pairs(options[i].groups) do
                if type(v) == 'string' then
                    jobs[v] = 0
                else
                    jobs = options[i].groups
                    break
                end
            end
            options[i].job = jobs
        end
        if options[i].items then
            options[i].item = options[i].items
        end
    end
    exports['core_focus']:AddGlobalVehicle({
        options = options,
        distance = options[1]?.distance or 2.0,
    })
end

P7H.Target.RemoveVehicle = function(optionNames)
    exports['core_focus']:RemoveGlobalVehicle(optionNames)
end

P7H.Target.AddModel = function(models, options)
    for i = 1, #options do
        if options[i].onSelect then
            options[i].action = options[i].onSelect
        end
        if options[i].groups then
            local jobs = {}
            for k, v in pairs(options[i].groups) do
                if type(v) == 'string' then
                    jobs[v] = 0
                else
                    jobs = options[i].groups
                    break
                end
            end
            options[i].job = jobs
        end
        if options[i].items then
            options[i].item = options[i].items
        end
    end
    exports['core_focus']:AddTargetModel(models, {
        options = options,
        distance = options[1]?.distance or 2.0,
    })
end

P7H.Target.RemoveModel = function(models, optionNames)
    exports['core_focus']:RemoveTargetModel(models, optionNames)
end

P7H.Target.AddEntity = function(netIds, options)
    local entities = {}
    if type(netIds) == 'number' then
        entities[1] = NetworkGetEntityFromNetworkId(netIds)
    else
        for i = 1, #netIds do
            entities[i] = NetworkGetEntityFromNetworkId(netIds[i])
        end
    end

    for i = 1, #options do
        if options[i].onSelect then
            options[i].action = options[i].onSelect
        end
        if options[i].groups then
            local jobs = {}
            for k, v in pairs(options[i].groups) do
                if type(v) == 'string' then
                    jobs[v] = 0
                else
                    jobs = options[i].groups
                    break
                end
            end
            options[i].job = jobs
        end
        if options[i].items then
            options[i].item = options[i].items
        end
    end
    exports['core_focus']:AddTargetEntity(netIds, {
        options = options,
        distance = options[1]?.distance or 2.0,
    })
end

P7H.Target.RemoveEntity = function(netIds, optionNames)
    local entities = {}
    if type(netIds) == 'number' then
        entities[1] = NetworkGetEntityFromNetworkId(netIds)
    else
        for i = 1, #netIds do
            entities[i] = NetworkGetEntityFromNetworkId(netIds[i])
        end
    end
    exports['core_focus']:RemoveTargetEntity(entities, optionNames)
end

P7H.Target.AddLocalEntity = function(entities, options)
    for i = 1, #options do
        if options[i].onSelect then
            options[i].action = options[i].onSelect
        end
        if options[i].groups then
            local jobs = {}
            for k, v in pairs(options[i].groups) do
                if type(v) == 'string' then
                    jobs[v] = 0
                else
                    jobs = options[i].groups
                    break
                end
            end
            options[i].job = jobs
        end
        if options[i].items then
            options[i].item = options[i].items
        end
    end
    exports['core_focus']:AddTargetEntity(entities, {
        options = options,
        distance = options[1]?.distance or 2.0,
    })
end

P7H.Target.RemoveLocalEntity = function(entities, optionNames)
    exports['core_focus']:RemoveTargetEntity(entities, optionNames)
end

P7H.Target.AddSphereZone = function(parameters)
    for i = 1, #parameters.options do
        if parameters.options[i].onSelect then
            parameters.options[i].action = parameters.options[i].onSelect
        end
        if parameters.options[i].groups then
            local jobs = {}
            for k, v in pairs(parameters.options[i].groups) do
                if type(v) == 'string' then
                    jobs[v] = 0
                else
                    jobs = parameters.options[i].groups
                    break
                end
            end
            parameters.options[i].job = jobs
        end
        if parameters.options[i].items then
            parameters.options[i].item = parameters.options[i].items
        end
    end
    local invoker = GetInvokingResource() or GetCurrentResourceName()
    local targetName = ('%s_%s_%s'):format(invoker, 'sphere', tostring(math.random(11111111, 99999999)))
    exports['core_focus']:AddCircleZone(targetName, parameters.coords, parameters.radius or 1.0, {
        name = targetName,
        debugPoly = Config.Debug,
        drawSprite = parameters.drawSprite or false,
    }, {
        options = parameters.options,
        distance = parameters.options[1]?.distance or 2.0
    })
    return targetName
end

P7H.Target.RemoveSphereZone = function(id)
    exports['qb-target']:RemoveZone(id)
end

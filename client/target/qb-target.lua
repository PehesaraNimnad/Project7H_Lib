if (Config.Target == 'auto' and checkResource('ox_target')) or (Config.Target ~= 'auto' and Config.Target ~= 'qb-target') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Target] Loaded: qb-target')
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
    exports['qb-target']:AddGlobalPlayer({
        options = options,
        distance = options[1]?.distance or 2.0,
    })
end

P7H.Target.RemovePlayer = function(optionNames)
    exports['qb-target']:RemoveGlobalPlayer(optionNames)
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
    exports['qb-target']:AddGlobalVehicle({
        options = options,
        distance = options[1]?.distance or 2.0,
    })
end

P7H.Target.RemoveVehicle = function(optionNames)
    exports['qb-target']:RemoveGlobalVehicle(optionNames)
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
    exports['qb-target']:AddTargetModel(models, {
        options = options,
        distance = options[1]?.distance or 2.0,
    })
end

P7H.Target.RemoveModel = function(models, optionNames)
    exports['qb-target']:RemoveTargetModel(models, optionNames)
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
    exports['qb-target']:AddTargetEntity(netIds, {
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
    exports['qb-target']:RemoveTargetEntity(entities, optionNames)
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
    exports['qb-target']:AddTargetEntity(entities, {
        options = options,
        distance = options[1]?.distance or 2.0,
    })
end

P7H.Target.RemoveLocalEntity = function(entities, optionNames)
    exports['qb-target']:RemoveTargetEntity(entities, optionNames)
end

P7H.Target.AddSphereZone = function(parameters)
    for i = 1, #parameters.options do
        if parameters.options[i].onSelect then
            parameters.options[i].action = parameters.options[i].onSelect
        end
        if parameters.options[i].groups then
            local jobs = {}
            if type(parameters.options[i].groups) == 'table' then
                for k, v in pairs(parameters.options[i].groups) do
                    if type(v) == 'string' then
                        jobs[v] = 0
                    else
                        jobs = parameters.options[i].groups
                        break
                    end
                end
            elseif type(parameters.options[i].groups) == 'string' then
                jobs[parameters.options[i].groups] = 0
            end
            parameters.options[i].job = jobs
        end
        if parameters.options[i].items then
            parameters.options[i].item = parameters.options[i].items
        end
    end
    local invoker = GetInvokingResource() or GetCurrentResourceName()
    local targetName = ('%s_%s_%s'):format(invoker, 'sphere', tostring(math.random(11111111, 99999999)))
    local radius = parameters.radius or 1.0
    exports['qb-target']:AddBoxZone(targetName, parameters.coords, radius * 2, radius * 2, {
        name = targetName,
        heading = 0,
        debugPoly = Config.Debug,
        drawSprite = parameters.drawSprite or false,
        minZ = parameters.coords.z - radius,
        maxZ = parameters.coords.z + radius + 1.0,
    }, {
        options = parameters.options,
        distance = parameters.options[1]?.distance or 2.0
    })
    return targetName
end

P7H.Target.RemoveSphereZone = function(id)
    exports['qb-target']:RemoveZone(id)
end

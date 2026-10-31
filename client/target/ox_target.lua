if (Config.Target == 'auto' and not checkResource('ox_target')) or (Config.Target ~= 'auto' and Config.Target ~= 'ox_target') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Target] Loaded: ox_target')
end

P7H.Target = {}

P7H.Target.Targets = {}

P7H.Target.ToggleTarget = function(state)
    exports['ox_target']:disableTargeting(not state)
end

P7H.Target.AddGlobal = function(options)
    local resourceName = GetInvokingResource() or cache.resource
    for i = 1, #options, 1 do
        P7H.Target.Targets[resourceName] = P7H.Target.Targets[resourceName] or {}
        table.insert(P7H.Target.Targets[resourceName], {type = 'global', name = options[i].name})
    end
    exports['ox_target']:addGlobalOption(options)
end

P7H.Target.RemoveGlobal = function(optionNames)
    exports['ox_target']:removeGlobalOption(optionNames)
end

P7H.Target.AddPlayer = function(options)
    local resourceName = GetInvokingResource() or cache.resource
    for i = 1, #options, 1 do
        P7H.Target.Targets[resourceName] = P7H.Target.Targets[resourceName] or {}
        table.insert(P7H.Target.Targets[resourceName], {type = 'player', name = options[i].name})
    end
    exports['ox_target']:addGlobalPlayer(options)
end

P7H.Target.RemovePlayer = function(optionNames)
    exports['ox_target']:removeGlobalPlayer(optionNames)
end

P7H.Target.AddVehicle = function(options)
    local resourceName = GetInvokingResource() or cache.resource
    for i = 1, #options, 1 do
        P7H.Target.Targets[resourceName] = P7H.Target.Targets[resourceName] or {}
        table.insert(P7H.Target.Targets[resourceName], {type = 'vehicle', name = options[i].name})
    end
    exports['ox_target']:addGlobalVehicle(options)
end

P7H.Target.RemoveVehicle = function(optionNames)
    exports['ox_target']:removeGlobalVehicle(optionNames)
end

P7H.Target.AddModel = function(models, options)
    local resourceName = GetInvokingResource() or cache.resource
    for i = 1, #options, 1 do
        P7H.Target.Targets[resourceName] = P7H.Target.Targets[resourceName] or {}
        table.insert(P7H.Target.Targets[resourceName], {type = 'model', model = models, name = options[i].name})
    end
    exports['ox_target']:addModel(models, options)
end

P7H.Target.RemoveModel = function(models, optionNames)
    exports['ox_target']:removeModel(models, optionNames)
end

P7H.Target.AddEntity = function(netIds, options)
    local resourceName = GetInvokingResource() or cache.resource
    for i = 1, #options, 1 do
        P7H.Target.Targets[resourceName] = P7H.Target.Targets[resourceName] or {}
        table.insert(P7H.Target.Targets[resourceName], {type = 'netEntity', netIds = netIds, name = options[i].name})
    end
    exports['ox_target']:addEntity(netIds, options)
end

P7H.Target.RemoveEntity = function(netIds, optionNames)
    exports['ox_target']:removeEntity(netIds, optionNames)
end

P7H.Target.AddLocalEntity = function(entities, options)
    local resourceName = GetInvokingResource() or cache.resource
    for i = 1, #options, 1 do
        P7H.Target.Targets[resourceName] = P7H.Target.Targets[resourceName] or {}
        table.insert(P7H.Target.Targets[resourceName], {type = 'localEntity', entities = entities, name = options[i].name})
    end
    exports['ox_target']:addLocalEntity(entities, options)
end

P7H.Target.RemoveLocalEntity = function(entities, optionNames)
    exports['ox_target']:removeLocalEntity(entities, optionNames)
end

P7H.Target.AddSphereZone = function(parameters)
    local resourceName = GetInvokingResource() or cache.resource
    local targetId = exports['ox_target']:addSphereZone(parameters)
    for i = 1, #parameters.options, 1 do
        P7H.Target.Targets[resourceName] = P7H.Target.Targets[resourceName] or {}
        table.insert(P7H.Target.Targets[resourceName], {type = 'sphereZone', id = targetId})
    end
    return targetId
end

P7H.Target.RemoveSphereZone = function(id)
    exports['ox_target']:removeZone(id)
end

AddEventHandler('onClientResourceStop', function(resourceName)
    if P7H.Target.Targets[resourceName] then
        for _, target in pairs(P7H.Target.Targets[resourceName]) do
            if target.type == 'model' then
                P7H.Target.RemoveModel(target.model, target.name)
            elseif target.type == 'netEntity' then
                P7H.Target.RemoveEntity(target.netIds, target.name)
            elseif target.type == 'localEntity' then
                P7H.Target.RemoveLocalEntity(target.entities, target.name)
            elseif target.type == 'player' then
                P7H.Target.RemovePlayer(target.name)
            elseif target.type == 'vehicle' then
                P7H.Target.RemoveVehicle(target.name)
            elseif target.type == 'sphereZone' then
                P7H.Target.RemoveSphereZone(target.id)
            elseif target.type == 'global' then
                P7H.Target.RemoveGlobal(target.name)
            end
        end
        P7H.Target.Targets[resourceName] = nil
    end
end)

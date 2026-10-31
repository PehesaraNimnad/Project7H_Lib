if (Config.Target == 'auto' and not checkResource('ContextMenu')) or (Config.Target ~= 'auto' and Config.Target ~= 'ContextMenu') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Target] Loaded: ContextMenu')
end

P7H.Target = {}
P7H.Target.Targets = {}

local ECM = exports['ContextMenu']

local registry = {
    global      = {},
    player      = {},
    vehicle     = {},
    model       = {},
    entity      = {},
    localEntity = {},
    sphere      = {},
}

local function toArray(value)
    if type(value) == 'table' then return value end
    return {value}
end

local function matchesModel(entityModel, models)
    for _, m in ipairs(models) do
        local hash = type(m) == 'string' and GetHashKey(m) or m
        if hash == entityModel then
            return true
        end
    end
    return false
end

local function tryAddItem(opt, hitEntity, distance, worldPosition)
    if opt.distance and distance > opt.distance then
        return
    end
    if opt.canInteract and not opt.canInteract(hitEntity, distance, worldPosition, opt.name, nil) then
        return
    end
    local itemId = ECM:AddItem(0, opt.label or opt.name, function()
        if opt.onSelect then
            opt.onSelect(hitEntity, worldPosition, opt.name)
        end
    end)
    if opt.disabled then
        ECM:Enabled(itemId, false)
    end
end

ECM:Register(function(screenPosition, hitSomething, worldPosition, hitEntity, normalDirection)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(worldPosition - playerCoords)

    for _, opt in pairs(registry.global) do
        tryAddItem(opt, hitEntity, distance, worldPosition)
    end

    if hitEntity and hitEntity ~= 0 then
        if IsPedAPlayer(hitEntity) then
            for _, opt in pairs(registry.player) do
                tryAddItem(opt, hitEntity, distance, worldPosition)
            end
        end

        if IsEntityAVehicle(hitEntity) then
            for _, opt in pairs(registry.vehicle) do
                tryAddItem(opt, hitEntity, distance, worldPosition)
            end
        end

        local entityModel = GetEntityModel(hitEntity)
        for _, entry in pairs(registry.model) do
            if matchesModel(entityModel, entry.models) then
                tryAddItem(entry.option, hitEntity, distance, worldPosition)
            end
        end

        if NetworkGetEntityIsNetworked(hitEntity) then
            local netId = NetworkGetNetworkIdFromEntity(hitEntity)
            for _, entry in pairs(registry.entity) do
                for _, id in ipairs(entry.netIds) do
                    if id == netId then
                        tryAddItem(entry.option, hitEntity, distance, worldPosition)
                        break
                    end
                end
            end
        end

        for _, entry in pairs(registry.localEntity) do
            for _, handle in ipairs(entry.entities) do
                if handle == hitEntity then
                    tryAddItem(entry.option, hitEntity, distance, worldPosition)
                    break
                end
            end
        end
    end

    for _, entry in pairs(registry.sphere) do
        local sphereDist = #(worldPosition - entry.coords)
        if sphereDist <= entry.radius then
            tryAddItem(entry.option, hitEntity, distance, worldPosition)
        end
    end
end)

P7H.Target.ToggleTarget = function(state)

end

P7H.Target.AddGlobal = function(options)
    local resourceName = GetInvokingResource() or cache.resource
    for i = 1, #options do
        P7H.Target.Targets[resourceName] = P7H.Target.Targets[resourceName] or {}
        table.insert(P7H.Target.Targets[resourceName], {type = 'global', name = options[i].name})
        registry.global[options[i].name] = options[i]
    end
end

P7H.Target.RemoveGlobal = function(optionNames)
    for _, name in ipairs(toArray(optionNames)) do
        registry.global[name] = nil
    end
end

P7H.Target.AddPlayer = function(options)
    local resourceName = GetInvokingResource() or cache.resource
    for i = 1, #options do
        P7H.Target.Targets[resourceName] = P7H.Target.Targets[resourceName] or {}
        table.insert(P7H.Target.Targets[resourceName], {type = 'player', name = options[i].name})
        registry.player[options[i].name] = options[i]
    end
end

P7H.Target.RemovePlayer = function(optionNames)
    for _, name in ipairs(toArray(optionNames)) do
        registry.player[name] = nil
    end
end

P7H.Target.AddVehicle = function(options)
    local resourceName = GetInvokingResource() or cache.resource
    for i = 1, #options do
        P7H.Target.Targets[resourceName] = P7H.Target.Targets[resourceName] or {}
        table.insert(P7H.Target.Targets[resourceName], {type = 'vehicle', name = options[i].name})
        registry.vehicle[options[i].name] = options[i]
    end
end

P7H.Target.RemoveVehicle = function(optionNames)
    for _, name in ipairs(toArray(optionNames)) do
        registry.vehicle[name] = nil
    end
end

P7H.Target.AddModel = function(models, options)
    local resourceName = GetInvokingResource() or cache.resource
    local normalizedModels = toArray(models)
    for i = 1, #options do
        P7H.Target.Targets[resourceName] = P7H.Target.Targets[resourceName] or {}
        table.insert(P7H.Target.Targets[resourceName], {type = 'model', model = models, name = options[i].name})
        registry.model[options[i].name] = {models = normalizedModels, option = options[i]}
    end
end

P7H.Target.RemoveModel = function(models, optionNames)
    for _, name in ipairs(toArray(optionNames)) do
        registry.model[name] = nil
    end
end

P7H.Target.AddEntity = function(netIds, options)
    local resourceName = GetInvokingResource() or cache.resource
    local normalizedNetIds = toArray(netIds)
    for i = 1, #options do
        P7H.Target.Targets[resourceName] = P7H.Target.Targets[resourceName] or {}
        table.insert(P7H.Target.Targets[resourceName], {type = 'netEntity', netIds = netIds, name = options[i].name})
        registry.entity[options[i].name] = {netIds = normalizedNetIds, option = options[i]}
    end
end

P7H.Target.RemoveEntity = function(netIds, optionNames)
    for _, name in ipairs(toArray(optionNames)) do
        registry.entity[name] = nil
    end
end

P7H.Target.AddLocalEntity = function(entities, options)
    local resourceName = GetInvokingResource() or cache.resource
    local normalizedEntities = toArray(entities)
    for i = 1, #options do
        P7H.Target.Targets[resourceName] = P7H.Target.Targets[resourceName] or {}
        table.insert(P7H.Target.Targets[resourceName], {type = 'localEntity', entities = normalizedEntities, name = options[i].name})
        registry.localEntity[options[i].name] = {entities = normalizedEntities, option = options[i]}
    end
end

P7H.Target.RemoveLocalEntity = function(entities, optionNames)
    for _, name in ipairs(toArray(optionNames)) do
        registry.localEntity[name] = nil
    end
end

P7H.Target.AddSphereZone = function(parameters)
    local resourceName = GetInvokingResource() or cache.resource
    local coords = parameters.coords
    local radius  = parameters.radius or 1.0
    for i = 1, #parameters.options do
        local opt = parameters.options[i]
        P7H.Target.Targets[resourceName] = P7H.Target.Targets[resourceName] or {}
        table.insert(P7H.Target.Targets[resourceName], {type = 'sphereZone', name = opt.name})
        registry.sphere[opt.name] = {coords = coords, radius = radius, option = opt}
    end

    return parameters.options[1] and parameters.options[1].name or nil
end

P7H.Target.RemoveSphereZone = function(id)
    registry.sphere[id] = nil
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
                P7H.Target.RemoveSphereZone(target.name)
            elseif target.type == 'global' then
                P7H.Target.RemoveGlobal(target.name)
            end
        end
        P7H.Target.Targets[resourceName] = nil
    end
end)

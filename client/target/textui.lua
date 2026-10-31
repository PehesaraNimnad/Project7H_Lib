if Config.Target ~= 'textui' then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Target] Loaded: textui')
end

P7H.Target = {}

P7H.Target.Targets = {}
P7H.Target.IsDisabled = false

local function targetToContext(options, entity)
    local contextOptions = {}
    for i = 1, #options, 1 do
        table.insert(contextOptions, {
            title = options[i].label,
            icon = options[i].icon or '',
            onSelect = function()
                options[i].onSelect(entity)
            end,
            disabled = options[i].canInteract and not options[i].canInteract(entity) or false,
        })
    end
    return contextOptions
end

local function getClosestEntity(entityType, distance, filter)
    local coords = GetEntityCoords(cache.ped)
    if entityType == 'player' then
        local plyId, plyPed, plyCoords = lib.getClosestPlayer(coords, distance, false)
        if plyPed and plyPed ~= 0 then
            return plyPed
        end
    elseif entityType == 'vehicle' then
        local vehicle, vehCoords = lib.getClosestVehicle(coords, distance, false)
        if vehicle and vehicle ~= 0 then
            return vehicle
        end
    else
        local objects = lib.getNearbyObjects(coords, distance)
        for _, obj in pairs(objects) do
            local objInfo = entityType == 'model' and joaat(GetEntityModel(obj.object)) or NetworkGetEntityFromNetworkId(obj.object)
            if type(filter) == 'string' then
                if objInfo == joaat(filter) then
                    return obj.object
                end
            elseif type(filter) == 'number' then
                if objInfo == filter then
                    return obj.object
                end
            elseif type(filter) == 'table' then
                if entityType == 'model' then
                    for _, model in pairs(filter) do
                        if objInfo == joaat(model) then
                            return obj.object
                        end
                    end
                else
                    for _, netId in pairs(filter) do
                        if objInfo == netId then
                            return obj.object
                        end
                    end
                end
            end
        end
    end
end

local lastEntity, lastOptions = nil
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1500)
        if P7H.Target.IsDisabled then
            goto skip
        end

        for _, target in pairs(P7H.Target.Targets) do
            local entity = getClosestEntity(target.type, 5.0, target.models or target.netIds or target.entities)
            if entity and (not lastEntity or entity ~= lastEntity) then
                lib.showTextUI('Press E to interact')
                lastEntity = entity
                lastOptions = target.options
            elseif lastEntity then
                lastEntity = nil
                lib.hideTextUI()
            end
        end
        ::skip::
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        if P7H.Target.IsDisabled then
            goto skip
        end

        if lastEntity then
            sleep = 1
            if IsControlJustReleased(0, 38) then
                local invoker = GetInvokingResource() or cache.resource
                local randomId = ('%s_%s'):format(invoker, math.random(1111111, 9999999))
                lib.registerContext({
                    id = randomId,
                    title = 'Interaction',
                    options = targetToContext(lastOptions, lastEntity)
                })
                lib.showContext(randomId)
            end
        end
        ::skip::
        Citizen.Wait(sleep)
    end
end)

P7H.Target.ToggleTarget = function(state)
    P7H.Target.IsDisabled = not state
end

P7H.Target.AddGlobal = function(options)
    return 'textUI'
end

P7H.Target.RemoveGlobal = function(optionNames)

end

P7H.Target.AddPlayer = function(options)
    local resourceName = GetInvokingResource() or cache.resource
    table.insert(P7H.Target.Targets, {
        type = 'player',
        options = options
    })
end

P7H.Target.RemovePlayer = function(optionNames)

end

P7H.Target.AddVehicle = function(options)
    local resourceName = GetInvokingResource() or cache.resource
    table.insert(P7H.Target.Targets, {
        type = 'vehicle',
        options = options
    })
end

P7H.Target.RemoveVehicle = function(optionNames)

end

P7H.Target.AddModel = function(models, options)
    local resourceName = GetInvokingResource() or cache.resource
    table.insert(P7H.Target.Targets, {
        type = 'model',
        models = models,
        options = options
    })
end

P7H.Target.RemoveModel = function(models, optionNames)
end

P7H.Target.AddEntity = function(netIds, options)
    local resourceName = GetInvokingResource() or cache.resource
    table.insert(P7H.Target.Targets, {
        type = 'netEntity',
        netIds = netIds,
        options = options
    })
end

P7H.Target.RemoveEntity = function(netIds, optionNames)

end

P7H.Target.AddLocalEntity = function(entities, options)
    local resourceName = GetInvokingResource() or cache.resource
    table.insert(P7H.Target.Targets, {
        type = 'localEntity',
        entities = entities,
        options = options
    })
end

P7H.Target.RemoveLocalEntity = function(entities, optionNames)

end

P7H.Target.AddSphereZone = function(parameters)
    local point = lib.points.new({
        coords = parameters.coords,
        distance = parameters.radius and parameters.radius + 1.0 or 3.0,
    })

    local invoker = GetInvokingResource() or cache.resource
    local randomId = ('%s_%s'):format(invoker, math.random(1111111, 9999999))

    function point:onEnter()
        lib.showTextUI('Press E to interact')
    end

    function point:onExit()
        lib.hideTextUI()
    end

    function point:nearby()
        if IsControlJustReleased(0, 38) then
            lib.registerContext({
                id = randomId,
                title = 'Interaction',
                options = targetToContext(parameters.options, nil)
            })
            lib.showContext(randomId)
        end
    end

    return point
end

P7H.Target.RemoveSphereZone = function(id)
    id:remove()
end

while not P7H do
    Citizen.Wait(0)
end

local SUPPORTED = { 'Project07_Spawn', 'Project07_DayzSpawn', 'Project07_RustSpawn', 'Project07_FreeSpawn', 'qbx_spawn' }

local function pick()
    local wanted = Config.Spawn or 'auto'
    if wanted == 'last' then return 'last' end
    if wanted ~= 'auto' then return GetResourceState(wanted) == 'started' and wanted or 'last' end
    for i = 1, #SUPPORTED do
        if GetResourceState(SUPPORTED[i]) == 'started' then return SUPPORTED[i] end
    end
    return 'last'
end

local function ours(which)
    return which == 'Project07_Spawn' or which == 'Project07_DayzSpawn' or which == 'Project07_RustSpawn'
end

local function hasMenu(which)
    return ours(which) or which == 'Project07_FreeSpawn'
end

P7H.Spawn = {}

P7H.Spawn.Name = pick

P7H.Spawn.Open = function(isNew)
    local which = pick()
    if hasMenu(which) then
        exports[which]:ShowMenu(isNew == true)
        return true
    elseif which == 'qbx_spawn' then
        TriggerEvent('qb-spawn:client:setupSpawns')
        TriggerEvent('qb-spawn:client:openUI', true)
        return true
    end
    return false
end

P7H.Spawn.HandlesApartments = function()
    return ours(pick())
end

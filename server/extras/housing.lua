while not P7H do
    Citizen.Wait(0)
end

local SUPPORTED = { 'qbx_properties', 'ps-housing', 'qb-houses' }

local function pick()
    local wanted = Config.Housing or 'auto'
    if wanted ~= 'auto' then return GetResourceState(wanted) == 'started' and wanted or 'none' end
    for i = 1, #SUPPORTED do
        if GetResourceState(SUPPORTED[i]) == 'started' then return SUPPORTED[i] end
    end
    return 'none'
end

local function decode(v)
    if type(v) ~= 'string' then return v end
    local ok, r = pcall(json.decode, v)
    return ok and r or nil
end

local qbxApartments
local function qbxOptions()
    if qbxApartments then return qbxApartments end
    local src = LoadResourceFile('qbx_properties', 'config/shared.lua')
    local chunk = src and load(src, '@qbx_properties/config/shared.lua', 't')
    local ok, conf = pcall(chunk or function() end)
    qbxApartments = ok and type(conf) == 'table' and conf.apartmentOptions or {}
    return qbxApartments
end

P7H.Housing = {}

P7H.Housing.Name = pick

P7H.Housing.GetApartments = function(fallback)
    local list = {}
    if pick() == 'qbx_properties' then
        for i, a in ipairs(qbxOptions()) do
            list[i] = { id = 'qbx_' .. i, index = i, label = a.label, description = a.description, coords = { x = a.enter.x, y = a.enter.y, z = a.enter.z } }
        end
        return list
    end
    for i, a in ipairs(fallback or {}) do list[i] = { id = a.id, label = a.label, image = a.image } end
    return list
end

P7H.Housing.HasApartment = function(citizenid)
    if pick() ~= 'qbx_properties' then return true end
    return MySQL.scalar.await('SELECT 1 FROM properties WHERE owner = ? LIMIT 1', { citizenid }) ~= nil
end

P7H.Housing.GetOwned = function(citizenid)
    local which = pick()
    local ok, rows
    if which == 'qbx_properties' then
        ok, rows = pcall(MySQL.query.await, 'SELECT id, property_name, coords FROM properties WHERE owner = ?', { citizenid })
        if not ok or not rows then return false end
        local list = {}
        for i, r in ipairs(rows) do
            local c = decode(r.coords)
            list[i] = { id = 'qbx_' .. r.id, label = r.property_name, coords = c and { x = c.x, y = c.y, z = c.z, w = c.w or 0.0 } or nil }
        end
        return list
    elseif which == 'ps-housing' then
        ok, rows = pcall(MySQL.query.await, 'SELECT property_id, street, region, door_data FROM properties WHERE owner_citizenid = ?', { citizenid })
        if not ok or not rows then return false end
        local list = {}
        for i, r in ipairs(rows) do
            local d = decode(r.door_data)
            list[i] = { id = 'ps_' .. r.property_id, propertyId = r.property_id, label = (r.street or 'Property') .. (r.region and (', ' .. r.region) or ''), coords = d and { x = d.x, y = d.y, z = d.z, w = d.h or 0.0 } or nil }
        end
        return list
    elseif which == 'qb-houses' then
        ok, rows = pcall(MySQL.query.await, 'SELECT house FROM player_houses WHERE citizenid = ?', { citizenid })
        if not ok or not rows then return false end
        local list = {}
        for i, r in ipairs(rows) do list[i] = { id = 'qb_' .. r.house, house = r.house, label = r.house } end
        return list
    end
    return false
end

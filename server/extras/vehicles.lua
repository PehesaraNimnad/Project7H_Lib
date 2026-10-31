while not P7H do
    Citizen.Wait(0)
end

P7H.Vehicles = P7H.Vehicles or {}

local function esx() return P7H.Framework.Name == 'esx' end

P7H.Vehicles.PlateExists = function(plate)
    local sql = esx() and 'SELECT 1 FROM owned_vehicles WHERE plate = ? LIMIT 1' or 'SELECT 1 FROM player_vehicles WHERE plate = ? LIMIT 1'
    return MySQL.scalar.await(sql, { plate }) ~= nil
end

---A free plate like "07AB1234" (8 characters).
P7H.Vehicles.GeneratePlate = function(prefix)
    prefix = (prefix or ''):upper():gsub('[^%w]', ''):sub(1, 4)
    for _ = 1, 40 do
        local plate = prefix
        while #plate < 8 do
            plate = plate .. (#plate % 3 == 2 and string.char(math.random(65, 90)) or tostring(math.random(0, 9)))
        end
        if not P7H.Vehicles.PlateExists(plate) then return plate end
    end
end

---Give a character an owned vehicle. Every garage reads it (qbx_vehicles, player_vehicles or owned_vehicles).
---@param src number online player
---@param model string spawn name
---@param opts? { garage?: string, plate?: string, props?: table }
---@return boolean ok, string? plate
P7H.Vehicles.AddOwned = function(src, model, opts)
    opts = opts or {}
    local owner = P7H.Framework.GetUniqueId(src)
    if not owner or type(model) ~= 'string' then return false end
    local plate = opts.plate or P7H.Vehicles.GeneratePlate()
    if not plate then return false end
    local props = opts.props or {}
    props.plate = plate
    props.model = props.model or joaat(model)
    local garage = opts.garage or 'pillboxgarage'

    if esx() then
        local ok = pcall(MySQL.insert.await, 'INSERT INTO owned_vehicles (owner, plate, vehicle, stored) VALUES (?, ?, ?, 1)', { owner, plate, json.encode(props) })
        return ok, plate
    end
    if GetResourceState('qbx_vehicles') == 'started' then
        local ok, id = pcall(function()
            return exports.qbx_vehicles:CreatePlayerVehicle({ model = model, citizenid = owner, props = props, garage = garage })
        end)
        if ok and id then return true, plate end
    end
    local ok = pcall(MySQL.insert.await,
        'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, 1)',
        { GetPlayerIdentifierByType(src, 'license'), owner, model, tostring(joaat(model)), json.encode(props), plate, garage })
    return ok, plate
end

---Every vehicle of the framework: { { model, label, brand, category, price, type } } (type = spawn type: automobile, bike, heli, boat ...)
P7H.Vehicles.GetVehicleList = function()
    local list = {}
    if GetResourceState('qbx_core') == 'started' then
        local ok, res = pcall(function() return exports.qbx_core:GetVehiclesByName() end)
        if ok and type(res) == 'table' then list = res end
    elseif GetResourceState('qb-core') == 'started' then
        local ok, res = pcall(function() return exports['qb-core']:GetCoreObject().Shared.Vehicles end)
        if ok and type(res) == 'table' then list = res end
    end
    local out = {}
    for model, v in pairs(list) do
        if type(model) == 'string' and type(v) == 'table' then
            out[#out + 1] = { model = model, label = ('%s %s'):format(v.brand or '', v.name or model):gsub('^%s+', ''), brand = v.brand, category = v.category, price = v.price, type = v.type }
        end
    end
    table.sort(out, function(a, b) return a.label < b.label end)
    return out
end

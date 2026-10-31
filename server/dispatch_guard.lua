-- Alerts sent by clients (P7H.Dispatch.SendAlert on the client -> net event) pass through here first:
-- rate limited per player, only known fields kept, every field cleaned, coords kept near the player.
-- Server-side calls of P7H.Dispatch.SendAlert are trusted and skip this.

local LIMIT = { gap = 4000, perMinute = 6 }
local MAX_DIST = 150.0
local PRIORITIES = { low = true, normal = true, medium = true, high = true, critical = true }
local recent = {}

local function str(v, max, pattern)
    if type(v) ~= 'string' then return nil end
    v = v:gsub('[<>%c]', ''):sub(1, max)
    if v == '' or (pattern and not v:match(pattern)) then return nil end
    return v
end

local function num(v, min, max)
    v = tonumber(v)
    if not v or v ~= v then return nil end
    return math.max(min, math.min(max, v))
end

local function jobs(v)
    if type(v) == 'string' then return str(v, 32, '^[%w_%-]+$') end
    if type(v) ~= 'table' then return nil end
    local out = {}
    for _, j in ipairs(v) do
        j = str(j, 32, '^[%w_%-]+$')
        if j then out[#out + 1] = j end
        if #out >= 6 then break end
    end
    return #out > 0 and out or nil
end

local function allowed(src)
    local now = GetGameTimer()
    local r = recent[src]
    if not r or now - r.start > 60000 then r = { start = now, count = 0, last = 0 } recent[src] = r end
    if now - r.last < LIMIT.gap or r.count >= LIMIT.perMinute then return false end
    r.last, r.count = now, r.count + 1
    return true
end

AddEventHandler('playerDropped', function() recent[source] = nil end)

--- Cleaned copy of a client's alert, or nil when it is refused.
---@param src number
---@param data any
---@return table?
function P7HDispatchGuard(src, data)
    if type(data) ~= 'table' or not allowed(src) then return nil end
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return nil end
    local here = GetEntityCoords(ped)

    local coords = here
    local c = data.coords
    if type(c) == 'vector3' or type(c) == 'vector4' or type(c) == 'table' then
        local x, y, z = tonumber(c.x), tonumber(c.y), tonumber(c.z)
        if x and y and z and #(here - vector3(x, y, z)) <= MAX_DIST then coords = vector3(x, y, z) end
    end

    local out = {
        coords = coords,
        street = str(data.street, 64),
        title = str(data.title, 80),
        message = str(data.message, 120),
        description = str(data.description, 200),
        information = str(data.information, 200),
        code = str(data.code, 16, '^[%w%-%s]+$'),
        codeName = str(data.codeName, 32, '^[%w_%-]+$'),
        type = str(data.type, 32, '^[%w_%-]+$'),
        icon = str(data.icon, 48, '^[%w%-%s]+$'),
        job = jobs(data.job),
        jobs = jobs(data.jobs),
        time = num(data.time, 1, 30),
        notify = num(data.notify, 1000, 15000),
        maxOfficers = num(data.maxOfficers, 1, 20),
        level = num(data.level, 1, 3),
    }
    local p = data.priority
    out.priority = (type(p) == 'string' and PRIORITIES[p] and p) or (num(p, 1, 3) and math.floor(num(p, 1, 3))) or nil

    if type(data.blip) == 'table' then
        local b = data.blip
        out.blip = {
            sprite = num(b.sprite, 1, 900), color = num(b.color, 0, 85), scale = num(b.scale, 0.3, 2.0),
            alpha = num(b.alpha, 0, 255), category = num(b.category, 0, 30), priority = num(b.priority, 0, 255),
            name = str(b.name, 40), short = b.short == true, flashes = b.flashes == true, hidden = b.hidden == true,
        }
    end
    if type(data.color) == 'table' then
        out.color = { num(data.color[1], 0, 255) or 255, num(data.color[2], 0, 255) or 0, num(data.color[3], 0, 255) or 0 }
    end
    if not (out.title or out.message or out.type) then return nil end
    return out
end

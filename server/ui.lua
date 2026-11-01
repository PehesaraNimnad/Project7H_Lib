--[[
    UI kit look: ui.json (preset, accent, scale, where each part sits, radial on / off) -> GlobalState['p7h:ui'],
    pushed live to every player. /p7hui reload reads the file again after an edit (admins).
    Server side notify for any resource: P7H.UI.Notify(src, data) or exports.Project7H_Lib:Notify(src, data).
]]

P7H.UI = P7H.UI or {}

local POSITIONS = { ['top-right'] = true, ['top-left'] = true, ['top'] = true, ['bottom'] = true, ['bottom-right'] = true, ['bottom-left'] = true, ['center-right'] = true, ['center-left'] = true, ['center'] = true }
local PRESETS = { clay = true, ink = true, glass = true, paper = true, steel = true }

local function clean(t)
    t = type(t) == 'table' and t or {}
    local pos = type(t.positions) == 'table' and t.positions or {}
    local function p(key, fallback) return POSITIONS[pos[key]] and pos[key] or fallback end
    local accent = type(t.accent) == 'string' and t.accent:match('^#%x%x%x%x%x%x$') and t.accent or '#f4f4f5'
    return {
        preset = PRESETS[t.preset] and t.preset or 'clay',
        accent = accent,
        scale = math.max(0.6, math.min(1.6, tonumber(t.scale) or 1.0)),
        radius = math.max(0, math.min(2, tonumber(t.radius) or 1.0)),
        opacity = math.max(0.5, math.min(1, tonumber(t.opacity) or 0.96)),
        positions = {
            notify = p('notify', 'top-right'), progress = p('progress', 'bottom'), menu = p('menu', 'center-right'),
            list = p('list', 'top-left'), textui = p('textui', 'center-left'), timeline = p('timeline', 'center-right'),
        },
        radial = { enabled = type(t.radial) == 'table' and t.radial.enabled == true or false, key = type(t.radial) == 'table' and type(t.radial.key) == 'string' and t.radial.key:sub(1, 10) or 'Z' },
    }
end

local function load()
    local raw = LoadResourceFile(GetCurrentResourceName(), 'ui.json')
    local ok, data = pcall(json.decode, raw or '{}')
    GlobalState['p7h:ui'] = clean(ok and data or {})
end
load()

lib.addCommand('p7hui', { help = 'Project7H UI kit: reload ui.json', params = { { name = 'action', type = 'string', help = 'reload' } }, restricted = 'group.admin' }, function(source, args)
    if args.action == 'reload' then
        load()
        if source > 0 then TriggerClientEvent('Project7H_Lib:ui:notify', source, { description = 'UI kit look reloaded', type = 'success' }) end
    end
end)

P7H.UI.Notify = function(src, data)
    if type(data) == 'string' then data = { description = data } end
    TriggerClientEvent('Project7H_Lib:ui:notify', src, data)
end
exports('Notify', P7H.UI.Notify)

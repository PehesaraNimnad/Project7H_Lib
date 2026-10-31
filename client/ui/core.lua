--[[
    Project7H UI kit: notify, progress bar / circle, context menu, list menu, input + confirm dialogs, text UI,
    radial menu. Drawn by web/ (React). Same arguments as the ox_lib functions, so scripts can switch by name.

    In another resource (after '@Project7H_Lib/imports.lua'):
        P7H.UI.Notify({ title, description, type, duration, icon })
        P7H.UI.ProgressBar(data) / P7H.UI.ProgressCircle(data)      -> true when finished (blocking)
        P7H.UI.RegisterContext(ctx) / P7H.UI.ShowContext(id) / P7H.UI.HideContext(onExit)
        P7H.UI.RegisterMenu(data, cb) / P7H.UI.ShowMenu(id) / P7H.UI.HideMenu(onExit)
        P7H.UI.InputDialog(heading, rows, options)                  -> values | nil (blocking)
        P7H.UI.AlertDialog(data)                                    -> 'confirm' | 'cancel' (blocking)
        P7H.UI.ShowTextUI(text, options) / P7H.UI.HideTextUI()
        P7H.UI.AddRadialItem(items) / RemoveRadialItem(id) / RegisterRadial(radial) / ShowRadial() / HideRadial()
    The same names are client exports of Project7H_Lib (blocking ones take a callback as last argument).
]]

local UI = {}
P7H.UI = UI

local function send(action, data) SendNUIMessage({ action = action, data = data }) end

local function iconName(icon)
    if type(icon) == 'table' then icon = icon[2] or icon[1] end
    if type(icon) ~= 'string' or icon == '' then return nil end
    if icon:find('fa%-') then return icon end
    return 'fa-solid fa-' .. icon
end
UI.IconName = iconName

-- ============================== THEME ==============================
-- web/ui.json → GlobalState['p7h:ui'] (server/ui.lua); pushed live to the NUI.

local function pushTheme(value) send('theme', value or GlobalState['p7h:ui'] or {}) end
AddStateBagChangeHandler('p7h:ui', 'global', function(_, _, value) pushTheme(value) end)
CreateThread(function()
    Wait(1000)
    pushTheme()
end)

-- ============================== FOCUS ==============================

local owners = {} -- who holds the NUI focus: menu / input / alert / list / radial

local function focus(owner, on, cursor)
    owners[owner] = on or nil
    local any, mouse = false, false
    for o in pairs(owners) do
        any = true
        if o ~= 'list' then mouse = true end
    end
    SetNuiFocus(any, mouse)
    if cursor == false then SetNuiFocusKeepInput(false) end
end

-- ============================== NOTIFY ==============================

---@param data { title?: string, description?: string, type?: string, duration?: number, icon?: string, position?: string, id?: string } | string
function UI.Notify(data)
    if type(data) == 'string' then data = { description = data } end
    if type(data) ~= 'table' then return end
    local kind = data.type == 'inform' and 'info' or data.type
    send('notify', {
        id = data.id, title = data.title and tostring(data.title) or nil, description = data.description and tostring(data.description) or nil,
        type = kind or 'info', duration = tonumber(data.duration) or 4000, icon = iconName(data.icon), position = data.position,
    })
end

RegisterNetEvent('Project7H_Lib:ui:notify', function(data)
    UI.Notify(data)
end)

-- ============================== CONTEXT MENU ==============================

local contexts, openContext = {}, nil

local function optionList(ctx)
    local opts = ctx.options or {}
    if opts[1] or next(opts) == nil then return opts end
    local list = {}
    for title, o in pairs(opts) do
        o.title = o.title or title
        list[#list + 1] = o
    end
    table.sort(list, function(a, b) return tostring(a.title) < tostring(b.title) end)
    ctx.options = list
    return list
end

local function metadataList(m)
    if type(m) ~= 'table' then return nil end
    local out = {}
    if m[1] then
        for _, v in ipairs(m) do
            if type(v) == 'table' then out[#out + 1] = { label = tostring(v.label or ''), value = v.value ~= nil and tostring(v.value) or nil }
            else out[#out + 1] = { label = tostring(v) } end
        end
    else
        for k, v in pairs(m) do out[#out + 1] = { label = tostring(k), value = tostring(v) } end
    end
    return out
end

function UI.RegisterContext(ctx)
    if type(ctx) ~= 'table' then return end
    if ctx.id then contexts[ctx.id] = ctx else for _, c in ipairs(ctx) do UI.RegisterContext(c) end end
end

function UI.ShowContext(id)
    local ctx = contexts[id]
    if not ctx then return print(('[Project7H_Lib] context %s is not registered'):format(tostring(id))) end
    local options = {}
    for i, o in ipairs(optionList(ctx)) do
        options[i] = {
            title = o.title and tostring(o.title) or '', description = o.description and tostring(o.description) or nil,
            icon = iconName(o.icon), iconColor = o.iconColor, disabled = o.disabled == true,
            readOnly = o.readOnly == true or (not o.onSelect and not o.menu and not o.event and not o.serverEvent and not o.disabled),
            arrow = o.arrow == true or o.menu ~= nil, progress = tonumber(o.progress), metadata = metadataList(o.metadata),
            image = type(o.image) == 'string' and o.image or nil,
        }
    end
    openContext = id
    focus('menu', true)
    send('menu', { id = id, title = ctx.title or '', back = ctx.menu ~= nil, canClose = ctx.canClose ~= false, options = options, position = ctx.position })
end

function UI.GetOpenContextMenu() return openContext end

function UI.HideContext(onExit)
    local id = openContext
    if not id then return end
    openContext = nil
    focus('menu', false)
    send('menuClose')
    local ctx = contexts[id]
    if onExit ~= false and ctx and ctx.onExit then ctx.onExit() end
end

RegisterNUICallback('ui:menuSelect', function(data, cb)
    cb(1)
    local ctx = openContext and contexts[openContext]
    if not ctx or type(data) ~= 'table' or data.id ~= openContext then return end
    local o = ctx.options[tonumber(data.index) or 0]
    if not o or o.disabled then return end
    openContext = nil
    if not o.menu then
        focus('menu', false)
        send('menuClose')
    end
    CreateThread(function()
        if o.onSelect then o.onSelect(o.args) end
        if o.menu then return UI.ShowContext(o.menu) end
        if o.event then TriggerEvent(o.event, o.args) end
        if o.serverEvent then TriggerServerEvent(o.serverEvent, o.args) end
    end)
end)

RegisterNUICallback('ui:menuBack', function(_, cb)
    cb(1)
    local ctx = openContext and contexts[openContext]
    if not ctx or not ctx.menu then return end
    if ctx.onBack then ctx.onBack() end
    openContext = nil
    UI.ShowContext(ctx.menu)
end)

RegisterNUICallback('ui:menuExit', function(_, cb)
    cb(1)
    local ctx = openContext and contexts[openContext]
    if ctx and ctx.canClose == false then return end
    UI.HideContext(true)
end)

-- ============================== LIST MENU (keyboard, like lib.registerMenu) ==============================

local lists, openList = {}, nil

---@param data { id: string, title: string, position?: string, options: table[], onSelected?: function, onSideScroll?: function, onCheck?: function, onClose?: function, canClose?: boolean }
---@param cb? fun(selected: integer, scrollIndex?: integer, args?: any, checked?: boolean)
function UI.RegisterMenu(data, cb)
    if type(data) ~= 'table' or not data.id then return end
    data.cb = cb
    lists[data.id] = data
end

local function listPayload(m)
    local options = {}
    for i, o in ipairs(m.options or {}) do
        options[i] = {
            label = tostring(o.label or ''), description = o.description and tostring(o.description) or nil, icon = iconName(o.icon),
            values = o.values, defaultIndex = o.defaultIndex, checked = o.checked, progress = tonumber(o.progress),
        }
        if type(o.values) == 'table' then
            local v = {}
            for vi, val in ipairs(o.values) do v[vi] = type(val) == 'table' and tostring(val.label or '') or tostring(val) end
            options[i].values = v
        end
    end
    return { id = m.id, title = m.title or '', position = m.position, options = options, canClose = m.canClose ~= false, start = m.startIndex or 1 }
end

function UI.ShowMenu(id, startIndex)
    local m = lists[id]
    if not m then return end
    if startIndex then m.startIndex = startIndex end
    openList = id
    focus('list', true)
    send('list', listPayload(m))
end

function UI.HideMenu(onExit)
    local m = openList and lists[openList]
    openList = nil
    focus('list', false)
    send('listClose')
    if m and onExit ~= false and m.onClose then m.onClose() end
end

function UI.GetOpenMenu() return openList end

function UI.SetMenuOptions(id, options, index)
    local m = lists[id]
    if not m then return end
    if index then m.options[index] = options else m.options = options end
    if openList == id then send('list', listPayload(m)) end
end

RegisterNUICallback('ui:listSelect', function(data, cb)
    cb(1)
    local m = openList and lists[openList]
    if not m or type(data) ~= 'table' then return end
    local i = tonumber(data.index) or 1
    local o = m.options[i]
    if not o then return end
    if o.close ~= false then UI.HideMenu(false) end
    CreateThread(function()
        if m.cb then m.cb(i, tonumber(data.scroll), o.args, data.checked) end
    end)
end)

RegisterNUICallback('ui:listChange', function(data, cb)
    cb(1)
    local m = openList and lists[openList]
    if not m or type(data) ~= 'table' then return end
    local i = tonumber(data.index) or 1
    local o = m.options[i]
    if data.kind == 'move' and m.onSelected then m.onSelected(i, tonumber(data.scroll), o and o.args)
    elseif data.kind == 'side' and o then
        o.defaultIndex = tonumber(data.scroll)
        if m.onSideScroll then m.onSideScroll(i, tonumber(data.scroll), o.args) end
    elseif data.kind == 'check' and o then
        o.checked = data.checked == true
        if m.onCheck then m.onCheck(i, o.checked, o.args) end
    end
end)

RegisterNUICallback('ui:listClose', function(_, cb)
    cb(1)
    local m = openList and lists[openList]
    if m and m.canClose == false then return end
    UI.HideMenu(true)
end)

-- ============================== INPUT DIALOG ==============================

local inputCb, inputRows
local ROW_TYPES = { input = true, number = true, checkbox = true, select = true, ['multi-select'] = true, slider = true, textarea = true, color = true, date = true }

---Callback style (exports). P7H.UI.InputDialog in imports.lua waits for it.
function UI.InputDialogAsync(heading, rows, options, cb)
    if inputCb then return cb(nil) end
    inputRows = {}
    local sendRows = {}
    for i, r in ipairs(rows or {}) do
        if type(r) == 'string' then r = { type = 'input', label = r } end
        r.type = ROW_TYPES[r.type] and r.type or 'input'
        inputRows[i] = r
        local opts, default = nil, r.default
        if r.options then
            opts = {}
            for oi, o in ipairs(r.options) do opts[oi] = { label = tostring(o.label or o.value), index = oi } end
            if r.type == 'select' then
                for oi, o in ipairs(r.options) do if o.value == default then default = oi end end
            elseif r.type == 'multi-select' and type(default) == 'table' then
                local picked = {}
                for oi, o in ipairs(r.options) do for _, d in ipairs(default) do if o.value == d then picked[#picked + 1] = oi end end end
                default = picked
            end
        end
        sendRows[i] = {
            type = r.type, label = r.label and tostring(r.label) or '', description = r.description, placeholder = r.placeholder,
            icon = iconName(r.icon), required = r.required == true, disabled = r.disabled == true, password = r.password == true,
            min = tonumber(r.min), max = tonumber(r.max), step = tonumber(r.step), default = default, checked = r.checked == true, options = opts,
        }
    end
    inputCb = cb
    focus('input', true)
    send('input', { heading = heading and tostring(heading) or '', rows = sendRows, allowCancel = not (options and options.allowCancel == false) })
end

function UI.CloseInputDialog()
    if not inputCb then return end
    local cb = inputCb
    inputCb, inputRows = nil, nil
    focus('input', false)
    send('inputClose')
    cb(nil)
end

RegisterNUICallback('ui:inputSubmit', function(data, cb)
    cb(1)
    if not inputCb then return end
    local done, rows = inputCb, inputRows
    inputCb, inputRows = nil, nil
    focus('input', false)
    if type(data) ~= 'table' or type(data.values) ~= 'table' then return done(nil) end
    local out = {}
    for i, r in ipairs(rows or {}) do
        local v = data.values[i]
        if v == nil and data.values[tostring(i)] ~= nil then v = data.values[tostring(i)] end
        if r.type == 'number' or r.type == 'slider' then out[i] = tonumber(v)
        elseif r.type == 'checkbox' then out[i] = v == true
        elseif r.type == 'select' then
            local o = r.options and r.options[tonumber(v) or 0]
            out[i] = o and o.value or nil
        elseif r.type == 'multi-select' then
            local list = {}
            for _, oi in ipairs(type(v) == 'table' and v or {}) do
                local o = r.options and r.options[tonumber(oi) or 0]
                if o then list[#list + 1] = o.value end
            end
            out[i] = list
        else out[i] = v ~= nil and tostring(v) or nil end
    end
    done(out)
end)

-- ============================== ALERT DIALOG ==============================

local alertCb

function UI.AlertDialogAsync(data, cb)
    if alertCb then return cb(nil) end
    data = type(data) == 'table' and data or {}
    alertCb = cb
    focus('alert', true)
    send('alert', {
        header = data.header and tostring(data.header) or '', content = data.content and tostring(data.content) or '',
        cancel = data.cancel == true, labels = { confirm = data.labels and data.labels.confirm, cancel = data.labels and data.labels.cancel },
    })
end

function UI.CloseAlertDialog()
    if not alertCb then return end
    local cb = alertCb
    alertCb = nil
    focus('alert', false)
    send('alertClose')
    cb(nil)
end

RegisterNUICallback('ui:alertAnswer', function(data, cb)
    cb(1)
    if not alertCb then return end
    local done = alertCb
    alertCb = nil
    focus('alert', false)
    done(type(data) == 'table' and data.answer == 'confirm' and 'confirm' or 'cancel')
end)

-- ============================== PROGRESS ==============================

local progress

local DISABLE = {
    move = { 21, 30, 31, 36 }, sprint = { 21 }, car = { 63, 64, 71, 72, 75 },
    combat = { 24, 25, 37, 47, 58, 140, 141, 142, 143, 257, 263, 264 }, mouse = { 1, 2, 106 },
}

local function attachProps(list)
    local out = {}
    if type(list) ~= 'table' then return out end
    if list.model then list = { list } end
    local coords = GetEntityCoords(cache.ped)
    for _, p in ipairs(list) do
        local model = type(p.model) == 'string' and joaat(p.model) or p.model
        if model and IsModelInCdimage(model) and pcall(lib.requestModel, model, 3000) then
            local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
            SetModelAsNoLongerNeeded(model)
            local pos, rot = p.pos or vec3(0, 0, 0), p.rot or vec3(0, 0, 0)
            AttachEntityToEntity(obj, cache.ped, GetPedBoneIndex(cache.ped, p.bone or 60309), pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, p.rotOrder or 0, true)
            out[#out + 1] = obj
        end
    end
    return out
end

---Blocking in the Lib's own thread; other resources use P7H.UI.ProgressBar (imports.lua) or the export with a callback.
local function runProgress(data, circle)
    if progress then return false end
    data = type(data) == 'table' and data or {}
    local duration = math.max(100, math.floor(tonumber(data.duration) or 1000))
    if not data.useWhileDead and IsEntityDead(cache.ped) then return false end
    local me = { cancelled = false }
    progress = me
    local anim = data.anim
    if type(anim) == 'table' then
        if anim.scenario then
            TaskStartScenarioInPlace(cache.ped, anim.scenario, 0, anim.playEnter ~= false)
        elseif anim.dict and pcall(lib.requestAnimDict, anim.dict, 3000) then
            TaskPlayAnim(cache.ped, anim.dict, anim.clip, anim.blendIn or 3.0, anim.blendOut or 1.0, anim.duration or -1, anim.flag or 49, anim.playbackRate or 0, anim.lockX, anim.lockY, anim.lockZ)
            RemoveAnimDict(anim.dict)
        end
    end
    local props = attachProps(data.prop)
    send('progress', { label = data.label and tostring(data.label) or '', duration = duration, circle = circle, canCancel = data.canCancel == true, position = data.position })
    local disable = type(data.disable) == 'table' and data.disable or {}
    local finish = GetGameTimer() + duration
    while GetGameTimer() < finish and not me.cancelled do
        for key, on in pairs(disable) do
            if on and DISABLE[key] then for _, c in ipairs(DISABLE[key]) do DisableControlAction(0, c, true) end end
        end
        if data.canCancel and IsControlJustPressed(0, 73) then me.cancelled = true end
        if not data.useWhileDead and IsEntityDead(cache.ped) then me.cancelled = true end
        Wait(0)
    end
    for _, obj in ipairs(props) do if DoesEntityExist(obj) then DeleteEntity(obj) end end
    if type(anim) == 'table' then
        if anim.scenario then ClearPedTasks(cache.ped) elseif anim.dict then StopAnimTask(cache.ped, anim.dict, anim.clip, 1.0) end
    end
    send('progressEnd', { cancelled = me.cancelled })
    progress = nil
    return not me.cancelled
end

function UI.ProgressBarAsync(data, cb) CreateThread(function() cb(runProgress(data, false)) end) end
function UI.ProgressCircleAsync(data, cb) CreateThread(function() cb(runProgress(data, true)) end) end
function UI.ProgressActive() return progress ~= nil end
function UI.CancelProgress() if progress then progress.cancelled = true end end
UI._runProgress = runProgress

-- ============================== TEXT UI ==============================

local textOpen = false

function UI.ShowTextUI(text, options)
    options = type(options) == 'table' and options or {}
    textOpen = true
    send('textui', { text = tostring(text or ''), icon = iconName(options.icon), position = options.position, key = options.key })
end

function UI.HideTextUI()
    textOpen = false
    send('textuiHide')
end

function UI.IsTextUIOpen() return textOpen, textOpen end

-- ============================== RADIAL ==============================
-- Off unless web/ui.json → radial.enabled (most servers already run a radial resource).

local radialItems, radials, radialOpen, radialDisabled = {}, {}, false, false
local radialStack = {}

local function addTo(list, items)
    if items.id then items = { items } end
    for _, item in ipairs(items) do
        for i = #list, 1, -1 do if list[i].id == item.id then table.remove(list, i) end end
        list[#list + 1] = item
    end
end

function UI.AddRadialItem(items) addTo(radialItems, items) end
function UI.RemoveRadialItem(id)
    for i = #radialItems, 1, -1 do if radialItems[i].id == id then table.remove(radialItems, i) end end
end
function UI.ClearRadialItems() radialItems = {} end
function UI.RegisterRadial(radial) if type(radial) == 'table' and radial.id then radials[radial.id] = radial end end
function UI.DisableRadial(state) radialDisabled = state == true end
function UI.GetCurrentRadialId() return radialStack[#radialStack] end

local function radialPayload(list, title)
    local items = {}
    for i, it in ipairs(list) do items[i] = { label = tostring(it.label or ''), icon = iconName(it.icon), menu = it.menu ~= nil } end
    return { title = title, items = items, back = #radialStack > 0 }
end

local function currentList()
    local id = radialStack[#radialStack]
    if not id then return radialItems, nil end
    local r = radials[id]
    return r and r.items or {}, r and r.label or nil
end

function UI.ShowRadial()
    if radialDisabled or #radialItems == 0 then return end
    radialOpen, radialStack = true, {}
    focus('radial', true)
    send('radial', radialPayload(radialItems))
end

function UI.HideRadial()
    if not radialOpen then return end
    radialOpen, radialStack = false, {}
    focus('radial', false)
    send('radialClose')
end

RegisterNUICallback('ui:radialSelect', function(data, cb)
    cb(1)
    local list = currentList()
    local it = list[(tonumber(type(data) == 'table' and data.index) or 0)]
    if not it then return end
    if it.menu then
        radialStack[#radialStack + 1] = it.menu
        local l, title = currentList()
        return send('radial', radialPayload(l, title))
    end
    if it.keepOpen ~= true then UI.HideRadial() end
    CreateThread(function()
        if it.onSelect then
            if type(it.onSelect) == 'string' then TriggerEvent(it.onSelect) else it.onSelect(radialStack[#radialStack], data.index) end
        end
    end)
end)

RegisterNUICallback('ui:radialBack', function(_, cb)
    cb(1)
    if #radialStack == 0 then return UI.HideRadial() end
    radialStack[#radialStack] = nil
    local l, title = currentList()
    send('radial', radialPayload(l, title))
end)

RegisterNUICallback('ui:radialClose', function(_, cb)
    cb(1)
    UI.HideRadial()
end)

CreateThread(function()
    Wait(1500)
    local t = GlobalState['p7h:ui'] or {}
    if not (t.radial and t.radial.enabled) then return end
    lib.addKeybind({
        name = 'p7h_radial', description = 'Radial menu', defaultKey = t.radial.key or 'Z',
        onPressed = function() if radialOpen then UI.HideRadial() else UI.ShowRadial() end end,
    })
end)

-- ============================== EXPORTS ==============================

local E = {
    Notify = UI.Notify,
    RegisterContext = UI.RegisterContext, ShowContext = UI.ShowContext, HideContext = UI.HideContext, GetOpenContextMenu = UI.GetOpenContextMenu,
    RegisterMenu = UI.RegisterMenu, ShowMenu = UI.ShowMenu, HideMenu = UI.HideMenu, GetOpenMenu = UI.GetOpenMenu, SetMenuOptions = UI.SetMenuOptions,
    InputDialog = UI.InputDialogAsync, CloseInputDialog = UI.CloseInputDialog,
    AlertDialog = UI.AlertDialogAsync, CloseAlertDialog = UI.CloseAlertDialog,
    ProgressBar = UI.ProgressBarAsync, ProgressCircle = UI.ProgressCircleAsync, ProgressActive = UI.ProgressActive, CancelProgress = UI.CancelProgress,
    ShowTextUI = UI.ShowTextUI, HideTextUI = UI.HideTextUI, IsTextUIOpen = UI.IsTextUIOpen,
    AddRadialItem = UI.AddRadialItem, RemoveRadialItem = UI.RemoveRadialItem, ClearRadialItems = UI.ClearRadialItems, RegisterRadial = UI.RegisterRadial,
    ShowRadial = UI.ShowRadial, HideRadial = UI.HideRadial, DisableRadial = UI.DisableRadial, GetCurrentRadialId = UI.GetCurrentRadialId,
}
for name, fn in pairs(E) do exports(name, fn) end

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if next(owners) then SetNuiFocus(false, false) end
end)

if (Config.Inventory == 'auto' and not checkResource('jaksam_inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'jaksam_inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: jaksam_inventory')
end

P7H.Inventory = {}

RegisterNetEvent('Project7H_Lib/inventory/openInventory', function(invType, data)
    local _source = source
    if invType ~= 'player' then return end

    local targetId = tonumber(type(data) == 'table' and (data.id or data.owner) or data)
    if not targetId then return end

    exports['jaksam_inventory']:forceOpenInventory(_source, targetId)
end)

P7H.Inventory.GetPlayerItems = function(playerId)
    return exports['jaksam_inventory']:getInventory(playerId)?.items or {}
end

P7H.Inventory.CustomDrop = function(prefix, items, coords)
   lib.print.error('CustomDrop is not supported in jaksam_inventory, please change type in config')
end

P7H.Inventory.AddItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['jaksam_inventory']:addItem(playerId, itemName, itemCount, itemMetadata, itemSlot)
end

P7H.Inventory.RemoveItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['jaksam_inventory']:removeItem(playerId, itemName, itemCount, itemMetadata, itemSlot)
end

P7H.Inventory.GetItemCount = function(playerId, itemName, itemMetadata)
    return exports['jaksam_inventory']:getTotalItemAmount(playerId, itemName, itemMetadata)
end

P7H.Inventory.GetItemSlot = function(playerId, slot)
    return exports['jaksam_inventory']:GetSlot(playerId, slot)
end

P7H.Inventory.CreateShop = function(shopName, data)
    while GetResourceState('jaksam_inventory') ~= 'started' do
        Citizen.Wait(100)
    end

    Citizen.Wait(100)
    exports['jaksam_inventory']:RegisterShop(shopName, data)
end

P7H.Inventory.GetItemData = function(itemName)
    return exports['jaksam_inventory']:getStaticItem(itemName)
end

P7H.Inventory.RegisterStash = function(stashId, label, slots, weight)
    return
end

P7H.Inventory.SetMetadata = function(playerId, slot, metadata)
    lib.print.error('setMetadata is not supported in jaksam_inventory, please change type in config')
end

P7H.Inventory.GetInventory = function(invId)
    return exports['jaksam_inventory']:getInventory(invId)
end

P7H.Inventory.ClearInventory = function(invId)
    local playerId = tonumber(invId)
    if not playerId then
        lib.print.error('clearInventory only supports player ids in jaksam_inventory')
        return
    end

    for _, item in pairs(P7H.Inventory.GetPlayerItems(playerId) or {}) do
        local amount = item.amount or item.count
        if item.name and amount and amount > 0 then
            P7H.Inventory.RemoveItem(playerId, item.name, amount, nil, item.slot)
        end
    end
end

P7H.Inventory.RegisterHook = function(event, cb, options)
    return nil
end

local usableItems = {}
local warnedMissing = {}
local originalRegisterItem = nil
local lastUse = {}
local lastReregister = 0
local DEBOUNCE_MS = 500
local ITEM_WAIT_MS = 60000

local reregisterNotify = {
    en = '%s usable items re-registered',
    de = '%s benutzbare Items neu angemeldet',
    pl = 'Ponownie zarejestrowano przedmioty: %s',
    fr = '%s objets utilisables réenregistrés',
    es = '%s objetos utilizables registrados de nuevo',
    it = '%s oggetti utilizzabili registrati di nuovo',
    tr = '%s kullanılabilir eşya yeniden kaydedildi',
    ru = 'Повторно зарегистрировано предметов: %s',
}

local function jaksamKnowsItem(itemName)
    local ok, data = pcall(function()
        return exports['jaksam_inventory']:getStaticItem(itemName)
    end)
    return ok and data ~= nil
end

local function registerWithJaksam(itemName)
    CreateThread(function()
        while GetResourceState('jaksam_inventory') ~= 'started' do
            Citizen.Wait(250)
        end

        local timeout = GetGameTimer() + ITEM_WAIT_MS
        while not jaksamKnowsItem(itemName) and GetGameTimer() < timeout do
            Citizen.Wait(500)
        end

        if not jaksamKnowsItem(itemName) then
            if not warnedMissing[itemName] then
                warnedMissing[itemName] = true
                lib.print.error(('[Inventory] Item "%s" is not defined in jaksam_inventory and cannot be used'):format(itemName))
            end
            return
        end

        local cb = usableItems[itemName]
        if not cb then return end

        if originalRegisterItem then
            pcall(originalRegisterItem, itemName, cb)
        end

        local ok, err = pcall(function()
            return exports['jaksam_inventory']:registerUsableItem(itemName, cb, 'Project7H_Lib')
        end)

        if not ok then
            lib.print.error(('[Inventory] registerUsableItem("%s") failed: %s'):format(itemName, tostring(err)))
        elseif Config.Debug then
            lib.print.info(('[Inventory] Registered usable item in jaksam_inventory: %s'):format(itemName))
        end
    end)
end

local function installUsableItemWrapper()
    local original = P7H.Framework.RegisterItem
    originalRegisterItem = original

    P7H.Framework.RegisterItem = function(itemName, itemFunction)
        local guarded = function(playerId, ...)
            if Config.Debug then
                lib.print.info(('[Inventory] Item used: %s (player %s, invoker %s)'):format(
                    tostring(itemName), tostring(playerId), tostring(GetInvokingResource())))
            end

            local key = ('%s:%s'):format(tostring(playerId), tostring(itemName))
            local now = GetGameTimer()
            if lastUse[key] and (now - lastUse[key]) < DEBOUNCE_MS then return end
            lastUse[key] = now

            local ok, err = pcall(itemFunction, playerId, ...)
            if not ok then
                lib.print.error(('[Inventory] Error in usable item callback "%s": %s'):format(tostring(itemName), tostring(err)))
            end
            return err
        end

        usableItems[itemName] = guarded
        original(itemName, guarded)
        registerWithJaksam(itemName)
    end
end

if type(P7H.Framework) == 'table' and type(P7H.Framework.RegisterItem) == 'function' then
    installUsableItemWrapper()
else
    lib.print.error('[Inventory] P7H.Framework is not loaded, usable items will not work with jaksam_inventory. Make sure your framework starts before Project7H_Lib.')
end

local function reregisterAll(reason)
    lastReregister = GetGameTimer()
    local count = 0
    for itemName in pairs(usableItems) do
        registerWithJaksam(itemName)
        count += 1
    end
    if Config.Debug then
        lib.print.info(('[Inventory] Re-registered %s usable items (%s)'):format(count, reason))
    end
    return count
end

lib.addCommand('reitems', {
    help = 'Re-register all usable items in jaksam_inventory',
    restricted = 'group.admin',
}, function(source)
    local count = reregisterAll('command')
    lib.print.info(('[Inventory] Re-registering %s usable items'):format(count))
    if source > 0 then
        local message = reregisterNotify[Config.Language] or reregisterNotify.en
        lib.notify(source, { title = message:format(count), type = 'success' })
    end
end)

local function scheduleDelayedReregister()
    CreateThread(function()
        while GetResourceState('jaksam_inventory') ~= 'started' do
            Citizen.Wait(500)
        end
        for _, delay in ipairs({ 15000, 45000, 120000 }) do
            Citizen.Wait(delay)
            reregisterAll(('%ss after jaksam_inventory start'):format(delay // 1000))
        end
    end)
end
scheduleDelayedReregister()

AddEventHandler('Project7H_Lib/server/playerLoaded', function()
    if GetGameTimer() - lastReregister < 10000 then return end
    SetTimeout(2000, function() reregisterAll('player loaded') end)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= 'jaksam_inventory' then return end
    reregisterAll('jaksam_inventory restarted')
    scheduleDelayedReregister()
end)

if (Config.Inventory == 'auto' and not checkResource('core_inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'core_inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: core_inventory')
end

P7H.Inventory = {}
P7H.Inventory.Items = {}

local function addItemData(name, data)
    P7H.Inventory.Items[name] = {
        name = name,
        label = data.label,
        weight = data.weight,
        description = data.description,
        image = ('https://cfx-nui-core_inventory/html/img/%s.png'):format(name)
    }
end

local function isQBCore()
    if Config.Framework == 'auto' then
        return checkResource('qb-core') or checkResource('qbx_core')
    end
    return Config.Framework == 'qb' or Config.Framework == 'qbox'
end

local function loadItems()
    if isQBCore() then

        local core = QBCore or exports['qb-core']:GetCoreObject()
        for name, data in pairs(core.Shared.Items or {}) do
            addItemData(name, data)
        end
        return
    end

    while not MySQL?.ready do
        Citizen.Wait(100)
    end

    local result = MySQL.query.await('SELECT * FROM items')
    for k, v in ipairs(result or {}) do
        addItemData(v.name, v)
    end
end

Citizen.CreateThread(loadItems)

P7H.Inventory.GetPlayerItems = function(playerId)
    local items = exports['core_inventory']:getItems(playerId)
    return items
end

P7H.Inventory.CustomDrop = function(prefix, items, coords)
    lib.print.error('CustomDrop is not supported in core_inventory, please change type in config')
end

P7H.Inventory.AddItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['core_inventory']:addItem(playerId, itemName, itemCount, itemMetadata)
end

P7H.Inventory.RemoveItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['core_inventory']:removeItem(playerId, itemName, itemCount)
end

P7H.Inventory.GetItemCount = function(playerId, itemName, itemMetadata)
    return exports.core_inventory:getItemCount(playerId, itemName)
end

P7H.Inventory.GetItemSlot = function(playerId, slot)
    local itemData = exports.core_inventory:getItemBySlot(playerId, slot)
    return itemData and {name = itemData.name, label = itemData.label, amount = itemData.amount or itemData.count, metadata = itemData.metadata or itemData.info or {}} or nil
end

P7H.Inventory.CreateShop = function(shopName, data)
    lib.print.error(('createShop is not supported in core_inventory, create the shop [%s] in core_inventory config'):format(shopName))
end

P7H.Inventory.GetItemData = function(itemName)
    return P7H.Inventory.Items[itemName]
end

P7H.Inventory.RegisterStash = function(stashId, label, slots, weight)
    return
end

P7H.Inventory.SetMetadata = function(playerId, slot, metadata)
    lib.print.error('setMetadata is not supported in core_inventory, please change type in config')
end

P7H.Inventory.GetInventory = function(invId)
    return { items = P7H.Inventory.GetPlayerItems(invId) }
end

P7H.Inventory.ClearInventory = function(invId)
    local playerId = tonumber(invId)
    if not playerId then
        lib.print.error('clearInventory only supports player ids in core_inventory')
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

lib.callback.register('Project7H_Lib/core_inventory/getItemsData', function()
    return P7H.Inventory.Items
end)

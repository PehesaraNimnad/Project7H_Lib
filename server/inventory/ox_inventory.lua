if (Config.Inventory == 'auto' and not checkResource('ox_inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'ox_inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: ox_inventory')
end

P7H.Inventory = {}

P7H.Inventory.GetPlayerItems = function(playerId)
    return exports['ox_inventory']:GetInventoryItems(playerId)
end

P7H.Inventory.CustomDrop = function(prefix, items, coords)
    exports['ox_inventory']:CustomDrop(prefix, items, coords)
end

P7H.Inventory.AddItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    return exports['ox_inventory']:AddItem(playerId, itemName, itemCount, itemMetadata, itemSlot) == true
end

P7H.Inventory.AddItemToStash = function(stashId, itemName, itemCount, itemMetadata)
    local success = exports['ox_inventory']:AddItem(stashId, itemName, itemCount, itemMetadata)
    return success and true or false
end

P7H.Inventory.RemoveItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    return exports['ox_inventory']:RemoveItem(playerId, itemName, itemCount, itemMetadata, itemSlot) == true
end

P7H.Inventory.GetItemCount = function(playerId, itemName, itemMetadata)
    return exports['ox_inventory']:Search(playerId, 'count', itemName, itemMetadata)
end

P7H.Inventory.GetItemSlot = function(playerId, slot)
    return exports['ox_inventory']:GetSlot(playerId, slot)
end

P7H.Inventory.CreateShop = function(shopName, data)
    while GetResourceState('ox_inventory') ~= 'started' do
        Citizen.Wait(100)
    end

    Citizen.Wait(100)
    exports['ox_inventory']:RegisterShop(shopName, data)
end

P7H.Inventory.GetItemData = function(itemName)
    return exports['ox_inventory']:Items(itemName)
end

P7H.Inventory.RegisterStash = function(stashId, label, slots, weight)
    while GetResourceState('ox_inventory') ~= 'started' do
        Citizen.Wait(100)
    end

    Citizen.Wait(100)
    exports['ox_inventory']:RegisterStash(stashId, label, slots, weight)
end

P7H.Inventory.SetMetadata = function(playerId, slot, metadata)
    exports['ox_inventory']:SetMetadata(playerId, slot, metadata)
end

P7H.Inventory.GetInventory = function(invId)
    return exports['ox_inventory']:GetInventory(invId)
end

P7H.Inventory.ClearInventory = function(invId)
    exports['ox_inventory']:ClearInventory(invId)
end

P7H.Inventory.RegisterHook = function(event, cb, options)
    return exports['ox_inventory']:registerHook(event, cb, options)
end

P7H.Inventory.CanCarryItem = function(playerId, itemName, itemCount, itemMetadata)
    return exports['ox_inventory']:CanCarryItem(playerId, itemName, itemCount or 1, itemMetadata) == true
end

P7H.Inventory.GetItemsByName = function(playerId, itemName)
    local out = {}
    for _, item in pairs(exports['ox_inventory']:Search(playerId, 'slots', itemName) or {}) do
        out[#out + 1] = { slot = item.slot, count = item.count, metadata = item.metadata or {} }
    end
    return out
end

---Every item: { { name, label } }, sorted by label.
P7H.Inventory.GetItemList = function()
    local out = {}
    for name, item in pairs(exports['ox_inventory']:Items() or {}) do
        out[#out + 1] = { name = name, label = item.label or name }
    end
    table.sort(out, function(a, b) return a.label < b.label end)
    return out
end

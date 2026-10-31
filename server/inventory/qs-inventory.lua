if (Config.Inventory == 'auto' and not checkResource('qs-inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'qs-inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: qs-inventory')
end

P7H.Inventory = {}

P7H.Inventory.GetPlayerItems = function(playerId)
    return exports['qs-inventory']:GetInventory(playerId) or {}
end

P7H.Inventory.CustomDrop = function(prefix, items, coords)
    lib.print.error('CustomDrop is not supported in qs-inventory, please change type in config')
end

P7H.Inventory.AddItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['qs-inventory']:AddItem(playerId, itemName, itemCount, itemSlot, itemMetadata)
end

P7H.Inventory.AddItemToStash = function(stashId, itemName, itemCount, itemMetadata, stashSlots, stashMaxWeight)
    local ok = pcall(function()
        exports['qs-inventory']:AddItemIntoStash(stashId, itemName, itemCount, nil, itemMetadata or {}, stashSlots, stashMaxWeight)
    end)
    return ok
end

P7H.Inventory.RemoveItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['qs-inventory']:RemoveItem(playerId, itemName, itemCount, itemSlot, itemMetadata)
end

P7H.Inventory.GetItemCount = function(playerId, itemName, itemMetadata)
    if itemMetadata then
        local items = exports['qs-inventory']:GetInventory(playerId)
        for k, v in pairs(items) do
            if v.name == itemName and v.info and lib.table.matches(v.info, itemMetadata) then
                return v.amount
            end
        end
    else
        return exports['qs-inventory']:GetItemTotalAmount(playerId, itemName)
    end

    return 0
end

P7H.Inventory.GetItemSlot = function(playerId, slot)
    local items = exports['qs-inventory']:GetInventory(playerId)
    local itemData = items[slot]
    return itemData and {name = itemData.name, label = itemData.label, amount = itemData.amount, metadata = itemData.info or {}} or nil
end

P7H.Inventory.CreateShop = function(shopName, data)
    return
end

P7H.Inventory.GetItemData = function(itemName)
    local items = exports['qs-inventory']:GetItemList()
    return items and items[itemName] or nil
end

P7H.Inventory.RegisterStash = function(stashId, label, slots, weight)
    return
end

P7H.Inventory.SetMetadata = function(playerId, slot, metadata)
    exports['qs-inventory']:SetItemMetadata(playerId, slot, metadata)
end

P7H.Inventory.GetInventory = function(invId)
    return { items = exports['qs-inventory']:GetInventory(invId) }
end

P7H.Inventory.ClearInventory = function(invId)
    exports['qs-inventory']:ClearInventory(invId)
end

P7H.Inventory.RegisterHook = function(event, cb, options)
    return nil
end

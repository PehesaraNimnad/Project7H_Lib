if (Config.Inventory == 'auto' and not checkResource('one_inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'one_inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: one_inventory')
end

P7H.Inventory = {}

P7H.Inventory.GetPlayerItems = function(playerId)
    return exports['one_inventory']:GetInventoryItems(playerId)
end

P7H.Inventory.CustomDrop = function(prefix, items, coords)
    exports['one_inventory']:CreateDrop(coords, items)
end

P7H.Inventory.AddItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['one_inventory']:AddItem(playerId, itemName, itemCount, itemMetadata, itemSlot)
end

P7H.Inventory.RemoveItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['one_inventory']:RemoveItem(playerId, itemName, itemCount, itemMetadata, itemSlot)
end

P7H.Inventory.GetItemCount = function(playerId, itemName, itemMetadata)
    return exports['one_inventory']:GetItemCount(playerId, itemName, itemMetadata)
end

P7H.Inventory.GetItemSlot = function(playerId, slot)
    return exports['one_inventory']:GetSlot(playerId, slot)
end

P7H.Inventory.CreateShop = function(shopName, data)
    while GetResourceState('one_inventory') ~= 'started' do
        Citizen.Wait(100)
    end

    Citizen.Wait(100)
    exports['one_inventory']:RegisterShop({
        name = shopName,
        label = data.name or data.label or 'Shop',
        coords = data.coords or data.locations,
        jobs = data.groups,
        inventory = data.inventory
    })
end

P7H.Inventory.GetItemData = function(itemName)
    return exports['one_inventory']:GetItemDefinition(itemName)
end

P7H.Inventory.RegisterStash = function(stashId, label, slots, weight)
    return
end

P7H.Inventory.SetMetadata = function(playerId, slot, metadata)
    exports['one_inventory']:SetItemMetadata(playerId, slot, metadata)
end

P7H.Inventory.GetInventory = function(invId)
    return exports['one_inventory']:GetInventory(invId)
end

P7H.Inventory.ClearInventory = function(invId)
    exports['one_inventory']:ClearInventory(invId)
end

P7H.Inventory.RegisterHook = function(event, cb, options)
    return exports['one_inventory']:RegisterHook(event, cb, options)
end

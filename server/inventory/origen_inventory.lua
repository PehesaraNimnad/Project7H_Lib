if (Config.Inventory == 'auto' and not checkResource('origen_inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'origen_inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: origen_inventory')
end

P7H.Inventory = {}

P7H.Inventory.GetPlayerItems = function(playerId)
    return exports['origen_inventory']:getInventoryItems(playerId)
end

P7H.Inventory.CustomDrop = function(prefix, items, coords)
    lib.print.error('CustomDrop is not supported in origen_inventory, please change type in config')
end

P7H.Inventory.AddItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['origen_inventory']:addItem(playerId, itemName, itemCount, itemMetadata, itemSlot)
end

P7H.Inventory.RemoveItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['origen_inventory']:removeItem(playerId, itemName, itemCount, itemMetadata, itemSlot)
end

P7H.Inventory.GetItemCount = function(playerId, itemName, itemMetadata)
    return exports['origen_inventory']:getItemCount(playerId, itemName, itemMetadata)
end

P7H.Inventory.GetItemSlot = function(playerId, slot)
    return exports['origen_inventory']:getSlot(playerId, slot)
end

P7H.Inventory.CreateShop = function(shopName, data)
    while GetResourceState('origen_inventory') ~= 'started' do
        Citizen.Wait(100)
    end
    exports['origen_inventory']:createShop(shopName, {
        label = data.name or 'Shop',
        slots = #data.inventory,
        items = data.inventory,
        locations = data.locations,
    })
end

P7H.Inventory.GetItemData = function(itemName)
    return exports['origen_inventory']:Items(itemName)
end

P7H.Inventory.RegisterStash = function(stashId, label, slots, weight)
    return
end

P7H.Inventory.SetMetadata = function(playerId, slot, metadata)
    lib.print.error('setMetadata is not supported in origen_inventory, please change type in config')
end

P7H.Inventory.GetInventory = function(invId)
    return { items = P7H.Inventory.GetPlayerItems(invId) }
end

P7H.Inventory.ClearInventory = function(invId)
    local playerId = tonumber(invId)
    if not playerId then
        lib.print.error('clearInventory only supports player ids in origen_inventory')
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

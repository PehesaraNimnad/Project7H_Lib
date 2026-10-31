if (Config.Inventory == 'auto' and not checkResource('ak47_qb_inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'ak47_qb_inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: ak47_qb_inventory')
end

P7H.Inventory = {}

P7H.Inventory.GetPlayerItems = function(playerId)
    return exports['ak47_qb_inventory']:GetInventoryItems(playerId)
end

P7H.Inventory.CustomDrop = function(prefix, items, coords)
    lib.print.error('ak47_qb_inventory does not support CustomDrop function, please change type in config')
end

P7H.Inventory.AddItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['ak47_qb_inventory']:AddItem(playerId, itemName, itemCount, itemSlot, itemMetadata)
end

P7H.Inventory.RemoveItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['ak47_qb_inventory']:RemoveItem(playerId, itemName, itemCount, itemSlot)
end

P7H.Inventory.GetItemCount = function(playerId, itemName, itemMetadata)
    return exports['ak47_qb_inventory']:getItemCount(playerId, 'count', itemName, itemMetadata)
end

P7H.Inventory.GetItemSlot = function(playerId, slot)
    local itemData = exports['ak47_qb_inventory']:getSlot(playerId, slot)
    return itemData and {name = itemData.name, label = itemData.label, amount = itemData.amount, metadata = itemData.info or {}} or nil
end

P7H.Inventory.CreateShop = function(shopName, data)
    while GetResourceState('ak47_qb_inventory') ~= 'started' do
        Citizen.Wait(100)
    end

    Citizen.Wait(100)
    exports['ak47_qb_inventory']:CreateShop(shopName, shopName, data, 'money')
end

P7H.Inventory.GetItemData = function(itemName)
    return exports['ak47_qb_inventory']:Items(itemName)
end

P7H.Inventory.RegisterStash = function(stashId, label, slots, weight)
    while GetResourceState('ak47_qb_inventory') ~= 'started' do
        Citizen.Wait(100)
    end

    Citizen.Wait(100)
    exports['ak47_qb_inventory']:CreateInventory(stashId, {
        label = label,
        slots = slots,
        maxWeight = weight,
        type = 'stash'
    })
end

P7H.Inventory.SetMetadata = function(playerId, slot, metadata)
    lib.print.error('setMetadata is not supported in ak47_qb_inventory, please change type in config')
end

P7H.Inventory.GetInventory = function(invId)
    return { items = P7H.Inventory.GetPlayerItems(invId) }
end

P7H.Inventory.ClearInventory = function(invId)
    local playerId = tonumber(invId)
    if not playerId then
        lib.print.error('clearInventory only supports player ids in ak47_qb_inventory')
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

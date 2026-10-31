if (Config.Inventory == 'auto' and not checkResource('codem-inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'codem-inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: codem-inventory')
end

P7H.Inventory = {}

P7H.Inventory.GetPlayerItems = function(playerId)
    local identifier = P7H.Framework.GetUniqueId(playerId)
    return exports['codem-inventory']:GetInventory(identifier, playerId)
end

P7H.Inventory.CustomDrop = function(prefix, items, coords)
    lib.print.error('CustomDrop is not supported in codem-inventory, please change type in config')
end

P7H.Inventory.AddItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['codem-inventory']:AddItem(playerId, itemName, itemCount, itemSlot, itemMetadata)
end

P7H.Inventory.RemoveItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['codem-inventory']:RemoveItem(playerId, itemName, itemCount, itemSlot)
end

P7H.Inventory.GetItemCount = function(playerId, itemName, itemMetadata)
    if itemMetadata then
        local items = exports['codem-inventory']:GetInventory(playerId)
        for k, v in pairs(items) do
            if v.name == itemName and v.info and lib.table.matches(v.info, itemMetadata) then
                return v.amount
            end
        end
    else
        return exports['codem-inventory']:GetItemsTotalAmount(playerId, itemName)
    end

    return 0
end

P7H.Inventory.GetItemSlot = function(playerId, slot)
    local itemData = exports['codem-inventory']:GetItemBySlot(playerId, slot)
    return itemData and {name = itemData.name, label = itemData.label, amount = itemData.amount, metadata = itemData.info or {}} or nil
end

P7H.Inventory.CreateShop = function(shopName, data)
    lib.print.error(('createShop is not supported in codem-inventory, create the shop [%s] in codem-inventory config'):format(shopName))
end

P7H.Inventory.GetItemData = function(itemName)
    local items = exports['codem-inventory']:GetItemList()
    return items and items[itemName] or nil
end

P7H.Inventory.RegisterStash = function(stashId, label, slots, weight)
    return
end

P7H.Inventory.SetMetadata = function(playerId, slot, metadata)
    lib.print.error('setMetadata is not supported in codem-inventory, please change type in config')
end

P7H.Inventory.GetInventory = function(invId)
    return { items = P7H.Inventory.GetPlayerItems(invId) }
end

P7H.Inventory.ClearInventory = function(invId)
    local playerId = tonumber(invId)
    if not playerId then
        lib.print.error('clearInventory only supports player ids in codem-inventory')
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

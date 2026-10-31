if (Config.Inventory == 'auto' and not checkResource('ps-inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'ps-inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: ps-inventory')
end

P7H.Inventory = {}

RegisterNetEvent('Project7H_Lib/inventory/openInventory', function(invType, data)
    if invType == 'shop' then
        exports['ps-inventory']:OpenShop(source, data.type)
    elseif invType == 'player' then
        exports['ps-inventory']:OpenInventoryById(source, data)
    else
        exports['ps-inventory']:OpenInventory(source, data)
    end
end)

P7H.Inventory.GetPlayerItems = function(playerId)
    return exports['ps-inventory']:GetInventory(playerId)?.items or {}
end

P7H.Inventory.CustomDrop = function(prefix, items, coords)
    lib.print.error('CustomDrop is not supported in ps-inventory, please change type in config')
end

P7H.Inventory.AddItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['ps-inventory']:AddItem(playerId, itemName, itemCount, itemSlot, itemMetadata)
end

P7H.Inventory.RemoveItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['ps-inventory']:RemoveItem(playerId, itemName, itemCount, itemSlot)
end

P7H.Inventory.GetItemCount = function(playerId, itemName, itemMetadata)
    if itemMetadata and QBCore then
        local Player = QBCore.Functions.GetPlayer(playerId)
        local items = Player.PlayerData.items
        for k, v in pairs(items) do
            if v.name == itemName and v.info and lib.table.matches(v.info, itemMetadata) then
                return v.amount
            end
        end
    else
        local itemData = exports['ps-inventory']:GetItemByName(playerId, itemName)
        if itemData then
            return itemData.count
        end
    end

    return 0
end

P7H.Inventory.GetItemSlot = function(playerId, slot)
    local itemSlot = exports['ps-inventory']:GetItemBySlot(playerId, slot)
    return itemSlot and {name = itemSlot.name, label = itemSlot.label, amount = itemSlot.amount, metadata = itemSlot.info or {}} or nil
end

P7H.Inventory.CreateShop = function(shopName, data)
    for i = 1, #data.inventory, 1 do
        if not data.inventory[i].slot then
            data.inventory[i].slot = i
        end

        if not data.inventory[i].amount then
            data.inventory[i].amount = 1000
        end
    end
    exports['ps-inventory']:CreateShop({
        name = shopName,
        label = data.label,
        slots = #data.inventory,
        items = data.inventory
    })
end

P7H.Inventory.GetItemData = function(itemName)
    return QBCore and QBCore.Shared.Items[itemName] or nil
end

P7H.Inventory.GetInventory = function(invId)
    return exports['ps-inventory']:GetInventory(invId)
end

P7H.Inventory.ClearInventory = function(invId)
    local playerId = tonumber(invId)
    if not playerId then
        lib.print.error('clearInventory only supports player ids in ps-inventory')
        return
    end

    for _, item in pairs(P7H.Inventory.GetPlayerItems(playerId) or {}) do
        local amount = item.amount or item.count
        if item.name and amount and amount > 0 then
            P7H.Inventory.RemoveItem(playerId, item.name, amount, nil, item.slot)
        end
    end
end

P7H.Inventory.RegisterStash = function(stashId, label, slots, weight)
    return
end

P7H.Inventory.SetMetadata = function(playerId, slot, metadata)
    lib.print.error('setMetadata is not supported in ps-inventory, please change type in config')
end

P7H.Inventory.RegisterHook = function(event, cb, options)
    return nil
end

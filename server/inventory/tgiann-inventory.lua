if (Config.Inventory == 'auto' and not checkResource('tgiann-inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'tgiann-inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: tgiann-inventory')
end

P7H.Inventory = {}

P7H.Inventory.GetPlayerItems = function(playerId)
    return exports['tgiann-inventory']:GetPlayerItems(playerId)
end

P7H.Inventory.CustomDrop = function(prefix, items, coords)
    exports['tgiann-inventory']:CustomDrop(prefix, items, coords)
end

P7H.Inventory.AddItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['tgiann-inventory']:AddItem(playerId, itemName, itemCount, itemSlot, itemMetadata)
end

P7H.Inventory.RemoveItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['tgiann-inventory']:RemoveItem(playerId, itemName, itemCount, itemSlot, itemMetadata)
end

P7H.Inventory.GetItemCount = function(playerId, itemName, itemMetadata)
    if itemMetadata then
        local items = exports['tgiann-inventory']:GetPlayerItems(playerId)
        for k, v in pairs(items) do
            if v.name == itemName and v.info and lib.table.matches(v.info, itemMetadata) then
                return v.amount
            end
        end
    else
        return exports['tgiann-inventory']:GetItemCount(playerId, itemName)
    end

    return 0
end

P7H.Inventory.GetItemSlot = function(playerId, slot)
    local items = exports['tgiann-inventory']:GetPlayerItems(playerId)
    local itemData = nil
    for k, v in pairs(items) do
        if v.slot == slot then
            itemData = v
            break
        end
    end
    return itemData and {name = itemData.name, label = itemData.label, amount = itemData.amount, metadata = itemData.info or {}} or nil
end

P7H.Inventory.GetItemData = function(itemName)
    return exports['tgiann-inventory']:Items(itemName)
end

P7H.Inventory.RegisterStash = function(stashId, label, slots, weight)
    while GetResourceState('tgiann-inventory') ~= 'started' do
        Citizen.Wait(100)
    end
    exports['tgiann-inventory']:RegisterStash(stashId, label, slots, weight)
end

P7H.Inventory.SetMetadata = function(playerId, slot, metadata)
    local itemData = exports["tgiann-inventory"]:GetItemBySlot(playerId, slot)

    if not itemData or not itemData.name then
        lib.print.error(
            ('Unable to update metadata: no item found for player %s in slot %s')
                :format(playerId, slot)
        )
        return false
    end

    return exports["tgiann-inventory"]:UpdateItemMetadata(
        playerId,
        itemData.name,
        slot,
        metadata
    )
end

P7H.Inventory.GetInventory = function(invId)
    return { items = P7H.Inventory.GetPlayerItems(invId) }
end

P7H.Inventory.ClearInventory = function(invId)
    local playerId = tonumber(invId)
    if not playerId then
        lib.print.error('clearInventory only supports player ids in tgiann-inventory')
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

P7H.Inventory.CreateShop = function(shopName, data)
    while GetResourceState('tgiann-inventory') ~= 'started' do
        Citizen.Wait(100)
    end

    for i = 1, #data.inventory, 1 do
        if not data.inventory[i].amount then
            data.inventory[i].amount = 9999
        end

        if not data.inventory[i].slot then
            data.inventory[i].slot = i
        end
        if data.inventory[i].name:find('WEAPON_') then
            data.inventory[i].type = 'weapon'
        else
            data.inventory[i].type = 'item'
        end
    end
    exports["tgiann-inventory"]:RegisterShop(shopName, data.inventory)
end

RegisterNetEvent('Project7H_Lib/inventory/openInventory', function(invType, data)
    if invType == 'stash' then

        local stashId = data.owner and ('%s_%s'):format(data.id, data.owner) or data.id
        local invData = nil
        if data.slots or data.maxWeight or data.label then
            invData = { slots = data.slots, maxWeight = data.maxWeight, label = data.label }
        end
        exports['tgiann-inventory']:OpenInventory(source, "stash", stashId, invData)
    elseif invType == 'player' then
        exports["tgiann-inventory"]:OpenInventoryById(source, data)
    elseif invType == 'shop' then
        exports["tgiann-inventory"]:OpenShop(source, data.type)
    end
end)

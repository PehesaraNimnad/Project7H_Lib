if (Config.Inventory == 'auto' and not (checkResource('S-Inventory') or checkResource('S-inventory'))) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'S-Inventory' and Config.Inventory ~= 'S-inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: S-inventory')
end

P7H.Inventory = {}

local ESX = exports['es_extended']:getSharedObject()

P7H.Inventory.GetPlayerItems = function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    return xPlayer.getInventory()
end

P7H.Inventory.CustomDrop = function(prefix, items, coords)

end

P7H.Inventory.AddItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    xPlayer.addInventoryItem(itemName, itemCount)
end

P7H.Inventory.RemoveItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    xPlayer.removeInventoryItem(itemName, itemCount, itemMetadata)
end

P7H.Inventory.GetItemCount = function(playerId, itemName, itemMetadata)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    return xPlayer.getInventoryItem(itemName)?.count or 0
end

P7H.Inventory.GetItemSlot = function(playerId, slot)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local items = xPlayer.getInventory()
    return items[slot]
end

P7H.Inventory.CreateShop = function(shopName, data)

end

P7H.Inventory.ItemsData = {}
GlobalState['Project7H_Lib:itemsData'] = P7H.Inventory.ItemsData

Citizen.CreateThread(function()
    while not MySQL?.ready do
        Citizen.Wait(100)
    end

    local result = MySQL.query.await('SELECT * FROM items')
    for k, v in pairs(result) do
        P7H.Inventory.ItemsData[v.name] = {
            label = v.label,
            description = v.description or v.label,
        }
    end
    GlobalState['Project7H_Lib:itemsData'] = P7H.Inventory.ItemsData
end)

P7H.Inventory.GetItemData = function(itemName)
    local info = P7H.Inventory.ItemsData[itemName]
    return info and {name = itemName, label = info.label, description = info.description} or nil
end

P7H.Inventory.RegisterStash = function(stashId, label, slots, weight)
    return
end

P7H.Inventory.SetMetadata = function(playerId, slot, metadata)
    lib.print.error('setMetadata is not supported in S-inventory, please change type in config')
end

P7H.Inventory.GetInventory = function(invId)
    return { items = P7H.Inventory.GetPlayerItems(invId) }
end

P7H.Inventory.ClearInventory = function(invId)
    local playerId = tonumber(invId)
    if not playerId then
        lib.print.error('clearInventory only supports player ids in S-inventory')
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

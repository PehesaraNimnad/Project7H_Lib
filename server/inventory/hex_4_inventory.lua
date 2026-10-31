if (Config.Inventory == 'auto' and not checkResource('hex_4_inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'hex_4_inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: hex_4_inventory')
end

P7H.Inventory = {}

local STASH_TYPE = 'fraction'

local registeredStashes = {}

local function getFramework()
    if ESX then return 'esx' end
    if QBCore then return 'qb' end
    if GetResourceState('qbx_core') == 'started' then return 'qbox' end
    return nil
end

local function getPlayer(playerId)
    playerId = tonumber(playerId)
    if not playerId then return nil end

    local fw = getFramework()
    if fw == 'esx' then
        return ESX.GetPlayerFromId(playerId)
    elseif fw == 'qb' then
        return QBCore.Functions.GetPlayer(playerId)
    elseif fw == 'qbox' then
        return exports.qbx_core:GetPlayer(playerId)
    end
    return nil
end

local function stashInventoryData(stashId)
    local meta = registeredStashes[stashId] or {}
    return {
        type = STASH_TYPE,
        id = stashId,
        title = meta.label or stashId,
        weight = meta.weight or false,
    }
end

RegisterNetEvent('Project7H_Lib/inventory/openInventory', function(invType, data)
    local _source = source
    if invType == 'stash' then
        local stashId = data.owner and ('%s_%s'):format(data.id, data.owner) or data.id
        local invData = stashInventoryData(stashId)
        if data.label then invData.title = data.label end
        if data.maxWeight then invData.weight = data.maxWeight end
        exports['hex_4_inventory']:OpenInventory(_source, invData)
    elseif invType == 'player' then
        local targetId = tonumber(type(data) == 'table' and data.id or data)
        if not targetId then return end
        if not GetPlayerName(targetId) then return end
        exports['hex_4_inventory']:OpenInventory(_source, {
            id = targetId,
            type = 'player',
            title = ('Player: %s'):format(GetPlayerName(targetId)),
        })
    elseif invType == 'shop' then
        lib.print.error(('hex_4_inventory has no shop export, create the shop [%s] in hex_4_inventory config'):format(data and data.type or 'unknown'))
    end
end)

P7H.Inventory.GetPlayerItems = function(playerId)
    local player = getPlayer(playerId)
    if not player then return {} end

    local out = {}
    local fw = getFramework()
    if fw == 'esx' then
        for _, item in pairs(player.getInventory() or {}) do
            if item.name and (item.count or 0) > 0 then
                out[#out + 1] = {
                    name = item.name,
                    label = item.label,
                    amount = item.count,
                    count = item.count,
                    metadata = item.metadata or item.info or {},
                    slot = item.slot,
                }
            end
        end
    else
        for _, item in pairs(player.PlayerData and player.PlayerData.items or {}) do
            if item and item.name and (item.amount or item.count or 0) > 0 then
                out[#out + 1] = {
                    name = item.name,
                    label = item.label,
                    amount = item.amount or item.count,
                    count = item.amount or item.count,
                    metadata = item.info or item.metadata or {},
                    slot = item.slot,
                }
            end
        end
    end
    return out
end

P7H.Inventory.CustomDrop = function(prefix, items, coords)
    lib.print.error('CustomDrop is not supported in hex_4_inventory, please change type in config')
end

P7H.Inventory.AddItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    local player = getPlayer(playerId)
    if not player then return false end

    if getFramework() == 'esx' then
        player.addInventoryItem(itemName, itemCount, itemMetadata)
        return true
    end
    return player.Functions.AddItem(itemName, itemCount, itemSlot, itemMetadata)
end

P7H.Inventory.RemoveItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    local player = getPlayer(playerId)
    if not player then return false end

    if getFramework() == 'esx' then
        player.removeInventoryItem(itemName, itemCount, itemMetadata)
        return true
    end
    return player.Functions.RemoveItem(itemName, itemCount, itemSlot)
end

P7H.Inventory.GetItemCount = function(playerId, itemName, itemMetadata)
    local count = 0
    for _, item in pairs(P7H.Inventory.GetPlayerItems(playerId)) do
        if item.name == itemName and (not itemMetadata or lib.table.matches(item.metadata or {}, itemMetadata)) then
            count = count + (item.amount or 0)
        end
    end
    return count
end

P7H.Inventory.GetItemSlot = function(playerId, slot)
    for _, item in pairs(P7H.Inventory.GetPlayerItems(playerId)) do
        if item.slot == slot then
            return { name = item.name, label = item.label, amount = item.amount, metadata = item.metadata or {} }
        end
    end
    return nil
end

P7H.Inventory.CreateShop = function(shopName, data)
    lib.print.error(('createShop is not supported in hex_4_inventory, create the shop [%s] in hex_4_inventory config'):format(shopName))
end

P7H.Inventory.GetItemData = function(itemName)
    local fw = getFramework()
    if fw == 'esx' then
        local item = ESX.Items and ESX.Items[itemName]
        return item and { name = itemName, label = item.label, description = item.description, weight = item.weight } or nil
    elseif fw == 'qb' then
        return QBCore.Shared.Items[itemName]
    elseif fw == 'qbox' then
        local items = exports.qbx_core:GetItems()
        return items and items[itemName] or nil
    end
    return nil
end

P7H.Inventory.RegisterStash = function(stashId, label, slots, weight)
    registeredStashes[stashId] = { label = label, slots = slots, weight = weight }
end

P7H.Inventory.AddItemToStash = function(stashId, itemName, itemCount, itemMetadata)
    local ok, success = pcall(function()
        return exports['hex_4_inventory']:AddItemToInventory(nil, nil, { name = itemName, metadata = itemMetadata or {} }, itemCount, stashInventoryData(stashId))
    end)
    if not ok and Config.Debug then
        lib.print.warn(('[Inventory] AddItemToInventory to stash %s failed: %s'):format(stashId, tostring(success)))
    end
    return ok and success and true or false
end

P7H.Inventory.SetMetadata = function(playerId, slot, metadata)
    lib.print.error('setMetadata is not supported in hex_4_inventory, please change type in config')
end

P7H.Inventory.GetInventory = function(invId)
    if tonumber(invId) then
        return { items = P7H.Inventory.GetPlayerItems(invId) }
    end

    local ok, inventory = pcall(function()
        return exports['hex_4_inventory']:GetInventory(nil, stashInventoryData(invId))
    end)
    if not ok then
        if Config.Debug then
            lib.print.warn(('[Inventory] GetInventory for stash %s failed: %s'):format(invId, tostring(inventory)))
        end
        return nil
    end
    if type(inventory) == 'table' and not inventory.items then
        return { items = inventory }
    end
    return inventory
end

P7H.Inventory.ClearInventory = function(invId)
    local playerId = tonumber(invId)
    if not playerId then
        exports['hex_4_inventory']:ClearInventory(STASH_TYPE, invId)
        return
    end

    local player = getPlayer(playerId)
    if player and getFramework() ~= 'esx' and player.Functions.ClearInventory then
        player.Functions.ClearInventory()
        return
    end

    for _, item in pairs(P7H.Inventory.GetPlayerItems(playerId)) do
        if item.name and (item.amount or 0) > 0 then
            P7H.Inventory.RemoveItem(playerId, item.name, item.amount, nil, item.slot)
        end
    end
end

P7H.Inventory.RegisterHook = function(event, cb, options)
    if type(event) ~= 'string' or type(cb) ~= 'function' then return nil end
    if not event:find(':', 1, true) then
        event = 'hex_4_inventory:' .. event
    end
    return exports['hex_4_inventory']:AddHook(event, cb)
end

P7H.Inventory.RemoveHook = function(hookId)
    if not hookId then return false end
    return exports['hex_4_inventory']:RemoveHook(hookId) and true or false
end

P7H.Inventory.ChangePlate = function(oldPlate, newPlate)
    exports['hex_4_inventory']:ChangeInventoryPlate(oldPlate, newPlate)
end

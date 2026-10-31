if (Config.Inventory == 'auto' and not checkResource('qb-inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'qb-inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: qb-inventory')
end

P7H.Inventory = {}

local hasNewApi
local function newApi()
    if hasNewApi == nil then
        hasNewApi = pcall(function()
            return exports['qb-inventory']:GetInventory('__Project7H_Lib_probe')
        end)
        if Config.Debug then
            lib.print.info(('[Inventory] qb-inventory API generation: %s'):format(hasNewApi and 'rewrite' or 'legacy'))
        end
    end
    return hasNewApi
end

RegisterNetEvent('Project7H_Lib/inventory/openInventory', function(invType, data)
    local _source = source
    if invType == 'shop' then
        exports['qb-inventory']:OpenShop(_source, data.type)
    elseif invType == 'player' then
        if newApi() then
            exports['qb-inventory']:OpenInventoryById(_source, tonumber(data))
        else

            TriggerClientEvent('inventory:client:SetCurrentStash', _source, 'otherplayer')
            TriggerEvent('inventory:server:OpenInventory', 'otherplayer', tostring(data))
        end
    else

        local stashId = data.owner and ('%s_%s'):format(data.id, data.owner) or data.id
        local stashData = nil
        if data.slots or data.maxWeight or data.label then
            stashData = { slots = data.slots, maxweight = data.maxWeight, label = data.label }
        end

        if newApi() then
            exports['qb-inventory']:OpenInventory(_source, stashId, stashData)
        else
            TriggerClientEvent('inventory:client:SetCurrentStash', _source, stashId)
            TriggerEvent('inventory:server:OpenInventory', 'stash', stashId, stashData or { maxweight = 4000000, slots = 50 })
        end
    end
end)

P7H.Inventory.GetPlayerItems = function(playerId)

    local Player = QBCore and QBCore.Functions.GetPlayer(tonumber(playerId))
    local items = Player and Player.PlayerData.items
    if not items and newApi() then
        items = exports['qb-inventory']:GetInventory(playerId)?.items
    end

    local out = {}
    for _, item in pairs(items or {}) do
        if item and item.name then
            out[#out + 1] = item
        end
    end
    return out
end

P7H.Inventory.CustomDrop = function(prefix, items, coords)
    lib.print.error('CustomDrop is not supported in qb-inventory, please change type in config')
end

P7H.Inventory.AddItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    exports['qb-inventory']:AddItem(playerId, itemName, itemCount, itemSlot, itemMetadata)
end

local function persistStash(stashId)
    if type(stashId) ~= 'string' or not newApi() then return end
    local inv = exports['qb-inventory']:GetInventory(stashId)
    if not inv or not inv.items then return end
    pcall(MySQL.query.await,
        'INSERT INTO inventories (identifier, items) VALUES (?, ?) ON DUPLICATE KEY UPDATE items = VALUES(items)',
        { stashId, json.encode(inv.items) })
end

P7H.Inventory.RemoveItem = function(playerId, itemName, itemCount, itemMetadata, itemSlot)
    local ok, result = pcall(function()
        return exports['qb-inventory']:RemoveItem(playerId, itemName, itemCount, itemSlot, 'Project7H_Lib:removeItem')
    end)
    if ok and result ~= false then
        persistStash(playerId)
    end
    return ok and result or nil
end

P7H.Inventory.GetItemCount = function(playerId, itemName, itemMetadata)
    if itemMetadata and QBCore then
        local Player = QBCore.Functions.GetPlayer(playerId)
        local items = Player and Player.PlayerData.items or {}
        for k, v in pairs(items) do
            if v.name == itemName and v.info and lib.table.matches(v.info, itemMetadata) then
                return v.amount
            end
        end
        return 0
    end

    if newApi() then
        return exports['qb-inventory']:GetItemCount(playerId, itemName)
    end

    local count = 0
    local Player = QBCore and QBCore.Functions.GetPlayer(tonumber(playerId))
    for _, item in pairs(Player and Player.PlayerData.items or {}) do
        if item.name == itemName then
            count = count + (item.amount or item.count or 0)
        end
    end
    return count
end

P7H.Inventory.GetItemSlot = function(playerId, slot)
    local itemSlot = exports['qb-inventory']:GetItemBySlot(playerId, slot)
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
    local ok = pcall(function()
        exports['qb-inventory']:CreateShop({
            name = shopName,
            label = data.label,
            slots = #data.inventory,
            items = data.inventory
        })
    end)
    if not ok then
        lib.print.error('CreateShop is not available in this qb-inventory build - update qb-inventory to use shops')
    end
end

lib.callback.register('Project7H_Lib/inventory/getPlayerItems', function(source)
    return P7H.Inventory.GetPlayerItems(source) or {}
end)

lib.callback.register('Project7H_Lib/inventory/getItemCount', function(source, itemName, itemMetadata)
    return P7H.Inventory.GetItemCount(source, itemName, itemMetadata) or 0
end)

P7H.Inventory.GetInventory = function(invId)
    if newApi() then
        return exports['qb-inventory']:GetInventory(invId)
    end
    return { items = P7H.Inventory.GetPlayerItems(invId) }
end

P7H.Inventory.ClearInventory = function(invId)
    if newApi() then
        exports['qb-inventory']:ClearInventory(invId)
        return
    end
    local Player = QBCore and QBCore.Functions.GetPlayer(tonumber(invId))
    if Player then
        Player.Functions.ClearInventory()
    end
end

P7H.Inventory.RegisterStash = function(stashId, label, slots, weight)
    return
end

local function legacyStashAdd(stashId, itemName, itemCount, itemMetadata, stashSlots)
    if not QBCore then return false end
    local itemInfo = QBCore.Shared.Items[itemName:lower()]
    if not itemInfo then return false end

    local raw = MySQL.scalar.await('SELECT items FROM stashitems WHERE stash = ?', { stashId })
    local items = {}
    if raw then
        for _, item in pairs(json.decode(raw) or {}) do
            if item and item.slot then items[item.slot] = item end
        end
    end

    local maxSlots = stashSlots or 50
    local slotToUse

    if not itemInfo.unique then
        for slot, item in pairs(items) do
            if item.name == itemName and lib.table.matches(item.info or {}, itemMetadata or {}) then
                item.amount = (item.amount or 0) + itemCount
                slotToUse = slot
                break
            end
        end
    end

    if not slotToUse then
        for slot = 1, maxSlots do
            if not items[slot] then
                items[slot] = {
                    name = itemInfo.name,
                    amount = itemCount,
                    info = itemMetadata or {},
                    label = itemInfo.label,
                    description = itemInfo.description or '',
                    weight = itemInfo.weight,
                    type = itemInfo.type,
                    unique = itemInfo.unique,
                    useable = itemInfo.useable,
                    image = itemInfo.image,
                    shouldClose = itemInfo.shouldClose,
                    combinable = itemInfo.combinable,
                    slot = slot,
                }
                slotToUse = slot
                break
            end
        end
    end

    if not slotToUse then return false end

    MySQL.query.await('INSERT INTO stashitems (stash, items) VALUES (?, ?) ON DUPLICATE KEY UPDATE items = VALUES(items)', {
        stashId, json.encode(items)
    })
    return true
end

P7H.Inventory.AddItemToStash = function(stashId, itemName, itemCount, itemMetadata, stashSlots, stashMaxWeight)
    if not newApi() then
        local ok, result = pcall(legacyStashAdd, stashId, itemName, itemCount, itemMetadata, stashSlots)
        return ok and result or false
    end

    local function tryAdd()
        local ok, success = pcall(function()
            return exports['qb-inventory']:AddItem(stashId, itemName, itemCount, nil, itemMetadata, 'Project7H_Lib:addItemToStash')
        end)
        if not ok and Config.Debug then
            lib.print.warn(('[Inventory] AddItem to stash %s failed: %s'):format(stashId, tostring(success)))
        end
        return ok and success and true or false
    end

    if not exports['qb-inventory']:GetInventory(stashId) then
        pcall(function()
            exports['qb-inventory']:CreateInventory(stashId, {
                label = stashId,
                slots = stashSlots or 50,
                maxweight = stashMaxWeight or 500000,
            })
        end)
    end

    local added = tryAdd()
    if added then
        persistStash(stashId)
    end
    return added
end

P7H.Inventory.SetMetadata = function(playerId, slot, metadata)

    lib.print.error('setMetadata is not supported in qb-inventory, please change type in config')
end

P7H.Inventory.RegisterHook = function(event, cb, options)
    return nil
end

P7H.Inventory.GetItemData = function(itemName)
    return QBCore and QBCore.Shared.Items[itemName] or nil
end

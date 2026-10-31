if (Config.Inventory == 'auto' and not checkResource('core_inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'core_inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: core_inventory')
end

P7H.Inventory = {}

P7H.Inventory.OpenInventory = function(invType, data)
    if invType == 'player' then
        TriggerServerEvent('core_inventory:server:openInventory', data, 'otherplayer', nil, nil, true)
    elseif invType == 'shop' then
        lib.print.error('core_inventory doesnt have export to open shop')
    elseif invType == 'stash' then
        TriggerServerEvent('core_inventory:server:openInventory', data.owner and ('%s_%s'):format(data.id, data.owner) or data.id, 'stash')
    end
end

P7H.Inventory.GetItemCount = function(itemName)
    return exports.core_inventory:getItemCount(itemName)
end

P7H.Inventory.GetItemData = function(itemName)
    local Items = lib.callback.await('Project7H_Lib/core_inventory/getItemsData', false)
    if Items[itemName] then
        return Items[itemName]
    end

    return nil
end

P7H.Inventory.GetPlayerItems = function()
    return exports.core_inventory:getInventory()
end

P7H.Inventory.GetCurrentWeapon = function()
    local weaponHash = GetSelectedPedWeapon(cache.ped)
    if not weaponHash or weaponHash == `WEAPON_UNARMED` then
        return nil
    end

    for _, item in pairs(P7H.Inventory.GetPlayerItems() or {}) do
        if item.name and GetHashKey(item.name) == weaponHash then
            return {name = item.name, label = item.label, metadata = item.metadata or item.info or {}, slot = item.slot}
        end
    end

    return nil
end

P7H.Inventory.Disarm = function(state)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
end

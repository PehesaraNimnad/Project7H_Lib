if (Config.Inventory == 'auto' and not checkResource('jaksam_inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'jaksam_inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: jaksam_inventory')
end

P7H.Inventory = {}

P7H.Inventory.OpenInventory = function(invType, data)

    if invType == 'player' then
        local targetId = tonumber(type(data) == 'table' and (data.id or data.owner) or data)
        if not targetId then return end
        TriggerServerEvent('Project7H_Lib/inventory/openInventory', invType, targetId)
        return
    end

    local invId = nil
    if type(data) == 'table' then
        if data.owner then
            invId = ('%s_%s'):format(data.id, data.owner)
        else
            invId = data.id
        end
    elseif type(data) == 'string' then
        invId = data
    end
    exports['jaksam_inventory']:openInventory(invId)
end

P7H.Inventory.GetItemCount = function(itemName)
    return exports['jaksam_inventory']:getTotalItemAmount(itemName)
end

P7H.Inventory.GetItemData = function(itemName)
    local info = exports['jaksam_inventory']:getStaticItem(itemName)
    return info and {name = itemName, label = info.label, description = info.description, image = ('https://cfx-nui-jaksam_inventory/_images/%s.png'):format(itemName)}
end

P7H.Inventory.GetPlayerItems = function()
    return exports['jaksam_inventory']:getInventory()?.items or {}
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

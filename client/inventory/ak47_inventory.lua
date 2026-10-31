if (Config.Inventory == 'auto' and not checkResource('ak47_inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'ak47_inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: ak47_inventory')
end

P7H.Inventory = {}

P7H.Inventory.OpenInventory = function(invType, data)
    exports['ak47_inventory']:OpenInventory(data)
end

P7H.Inventory.GetItemCount = function(itemName)
    return exports['ak47_inventory']:Search('amount', itemName)
end

P7H.Inventory.GetItemData = function(itemName)
    local info = exports['ak47_inventory']:Items(itemName)
    return info and {name = itemName, label = info.label, description = info.description, image = ('https://cfx-nui-ak47_inventory/web/images/%s.png'):format(itemName)} or nil
end

P7H.Inventory.GetPlayerItems = function()
    return exports['ak47_inventory']:GetPlayerItems()
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

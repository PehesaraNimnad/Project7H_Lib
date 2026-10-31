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

P7H.Inventory.OpenInventory = function(invType, data)
    TriggerServerEvent('Project7H_Lib/inventory/openInventory', invType, data)
end

P7H.Inventory.GetItemCount = function(itemName)
    return exports['tgiann-inventory']:Search('count', itemName)
end

P7H.Inventory.GetItemData = function(itemName)
    local info = exports["tgiann-inventory"]:Items(itemName)
    return info and {name = itemName, label = info.label, description = info.description, image = ('nui://inventory_images/images/%s.png'):format(itemName)}
end

P7H.Inventory.GetPlayerItems = function()
    return exports["tgiann-inventory"]:GetPlayerItems()
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

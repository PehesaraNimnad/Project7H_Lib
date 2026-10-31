if (Config.Inventory == 'auto' and not (checkResource('S-Inventory') or checkResource('S-inventory'))) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'S-Inventory' and Config.Inventory ~= 'S-inventory') then
    return
end

local ESX = exports['es_extended']:getSharedObject()

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: S-Inventory')
end

P7H.Inventory = {}

P7H.Inventory.OpenInventory = function(invType, data)
    if invType == 'player' then
        TriggerEvent("SService:Server:SearchPlayer")
    elseif invType == 'stash' then
        exports["S-Inventory"]:OpenStashInventory(nil, data)
    elseif invType == 'shop' then
        lib.print.error('S-Inventory does not support external shops, create shop in inventory config')
    end
end

P7H.Inventory.GetItemCount = function(itemName)
    local items = ESX.GetPlayerData().inventory
    if items then
        for k, v in pairs(items) do
            if v.name == itemName then
                return v.count or 0
            end
        end
    end
end

P7H.Inventory.GetItemData = function(itemName)
    local info = GlobalState['Project7H_Lib:itemsData'][itemName]
    return info and {name = itemName, label = info.label, description = info.description, image = ('https://cfx-nui-ox_inventory/web/images/%s.png'):format(itemName)}
end

P7H.Inventory.GetPlayerItems = function()
    return ESX.GetPlayerData().inventory
end

P7H.Inventory.GetCurrentWeapon = function()
    local weaponHash = GetSelectedPedWeapon(cache.ped)
    if not weaponHash or weaponHash == `WEAPON_UNARMED` then
        return nil
    end

    local loadout = ESX.GetPlayerData().loadout or {}
    for _, weapon in pairs(loadout) do
        if GetHashKey(weapon.name) == weaponHash then
            return {name = weapon.name, label = weapon.label, metadata = {ammo = weapon.ammo, components = weapon.components}}
        end
    end

    return nil
end

P7H.Inventory.Disarm = function(state)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
end

if (Config.Inventory == 'auto' and not checkResource('jpr-inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'jpr-inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: jpr-inventory')
end

P7H.Inventory = {}

P7H.Inventory.OpenInventory = function(invType, data)
    if invType == 'stash' then
        if data.owner then
            TriggerServerEvent("inventory:server:OpenInventory", "stash", data.id..'_'..data.owner, {
                maxweight = 250000,
                slots = 100,
            })
            TriggerEvent("inventory:client:SetCurrentStash", data.id..'_'..data.owner)
        else
            TriggerServerEvent('Project7H_Lib/inventory/openInventory', invType, data)
        end
    elseif invType == 'shop' then
        TriggerServerEvent('Project7H_Lib/inventory/openInventory', invType, data)
    elseif invType == 'player' then
        TriggerServerEvent("inventory:server:OpenInventory", "otherplayer", data)
        TriggerEvent("inventory:client:SetCurrentStash", "otherplayer")
    end
end

P7H.Inventory.GetItemCount = function(itemName)
    local items = QBCore.PlayerData.items
    for _, item in pairs(items) do
        if item.name == itemName then
            return item.amount
        end
    end
    return 0
end

P7H.Inventory.GetItemData = function(itemName)
    local info = exports["jpr-inventory"]:GetItemList()[itemName]
    return info and {name = itemName, label = info.label, description = info.description, image = ('https://cfx-nui-jpr-inventory/html/images/%s.png'):format(itemName)}
end

P7H.Inventory.GetPlayerItems = function()
    return QBCore.PlayerData.items
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

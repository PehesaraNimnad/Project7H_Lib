if (Config.Inventory == 'auto' and not checkResource('ox_inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'ox_inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: ox_inventory')
end

P7H.Inventory = {}

P7H.Inventory.OpenInventory = function(invType, data)
    exports['ox_inventory']:openInventory(invType, data)
end

P7H.Inventory.GetItemCount = function(itemName, metadata)
    return exports['ox_inventory']:Search('count', itemName, metadata or nil)
end

P7H.Inventory.GetItemData = function(itemName)
    local info = exports['ox_inventory']:Items(itemName)
    return info and {name = itemName, label = info.label, description = info.description, image = ('https://cfx-nui-ox_inventory/web/images/%s.png'):format(itemName)}
end

P7H.Inventory.GetPlayerItems = function()
    return exports['ox_inventory']:GetPlayerItems()
end

P7H.Inventory.GetCurrentWeapon = function()
    return exports.ox_inventory:getCurrentWeapon()
end

P7H.Inventory.Disarm = function(state)
    TriggerEvent('ox_inventory:disarm', true)
end

P7H.Inventory.GetItemsByName = function(itemName)
    local out = {}
    for _, item in pairs(exports['ox_inventory']:Search('slots', itemName) or {}) do
        out[#out + 1] = { slot = item.slot, count = item.count, metadata = item.metadata or {} }
    end
    return out
end

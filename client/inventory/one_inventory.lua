if (Config.Inventory == 'auto' and not checkResource('one_inventory')) or (Config.Inventory ~= 'auto' and Config.Inventory ~= 'one_inventory') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Inventory] Loaded: one_inventory')
end

P7H.Inventory = {}

P7H.Inventory.OpenInventory = function(invType, data)
    exports['one_inventory']:OpenInventory(invType, data)
end

P7H.Inventory.GetItemCount = function(itemName, metadata)
    return exports['one_inventory']:GetItemCount(itemName, metadata or nil)
end

P7H.Inventory.GetItemData = function(itemName)
    local info = exports['one_inventory']:GetItemDefinition(itemName)
    if not info then
        return
    end

    local image = info.image or ('%s.png'):format(itemName)
    if not image:find('^https?://') then
        if not image:find('%.') then
            image = ('%s.png'):format(image)
        end
        image = ('https://cfx-nui-one_inventory/web/images/%s'):format(image)
    end

    return {name = itemName, label = info.label, description = info.description, image = image}
end

P7H.Inventory.GetPlayerItems = function()
    return exports['one_inventory']:GetInventoryItems()
end

P7H.Inventory.GetCurrentWeapon = function()
    return exports['one_inventory']:GetEquippedWeapon()
end

P7H.Inventory.Disarm = function(state)
    exports['one_inventory']:DisarmPlayer()
end

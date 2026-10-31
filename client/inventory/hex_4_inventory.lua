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

local function getFramework()
    if ESX then return 'esx' end
    if QBCore then return 'qb' end
    if GetResourceState('qbx_core') == 'started' then return 'qbox' end
    return nil
end

local function getRawItems()
    local fw = getFramework()
    if fw == 'esx' then
        return ESX.GetPlayerData().inventory or {}
    elseif fw == 'qb' then
        return QBCore.Functions.GetPlayerData().items or {}
    elseif fw == 'qbox' then
        return exports.qbx_core:GetPlayerData()?.items or {}
    end
    return {}
end

P7H.Inventory.OpenInventory = function(invType, data)
    if invType == 'trunk' then
        exports['hex_4_inventory']:OpenTrunk()
        return
    elseif invType == 'glovebox' then
        exports['hex_4_inventory']:OpenGlove()
        return
    end
    TriggerServerEvent('Project7H_Lib/inventory/openInventory', invType, data)
end

P7H.Inventory.CloseInventory = function()
    exports['hex_4_inventory']:CloseInventory()
end

P7H.Inventory.LockInventory = function(state)
    exports['hex_4_inventory']:LockInventory(state and true or false)
end

P7H.Inventory.GetItemCount = function(itemName)
    local count = 0
    for _, item in pairs(getRawItems()) do
        if item and item.name == itemName then
            count = count + (item.amount or item.count or 0)
        end
    end
    return count
end

P7H.Inventory.GetItemData = function(itemName)
    local info
    local fw = getFramework()
    if fw == 'qb' then
        info = QBCore.Shared.Items[itemName]
    elseif fw == 'qbox' then
        local items = exports.qbx_core:GetItems()
        info = items and items[itemName] or nil
    else

        for _, item in pairs(getRawItems()) do
            if item.name == itemName then
                info = item
                break
            end
        end
    end

    return info and {name = itemName, label = info.label, description = info.description, image = ('https://cfx-nui-hex_4_inventory/img/icons/%s.png'):format(itemName)}
end

P7H.Inventory.GetPlayerItems = function()
    local formatted = {}
    for _, item in pairs(getRawItems()) do
        if item and item.name and (item.amount or item.count or 0) > 0 then
            formatted[#formatted + 1] = {
                name = item.name,
                label = item.label or item.name,
                amount = item.amount or item.count or 0,
                count = item.amount or item.count or 0,
                metadata = item.info or item.metadata or {},
                slot = item.slot
            }
        end
    end
    return formatted
end

P7H.Inventory.GetCurrentWeapon = function()
    local weaponHash = GetSelectedPedWeapon(cache.ped)
    if not weaponHash or weaponHash == `WEAPON_UNARMED` then
        return nil
    end

    for _, item in pairs(P7H.Inventory.GetPlayerItems() or {}) do
        if item.name and GetHashKey(item.name) == weaponHash then
            return {name = item.name, label = item.label, metadata = item.metadata or {}, slot = item.slot}
        end
    end

    if getFramework() == 'esx' then
        for _, weapon in pairs(ESX.GetPlayerData().loadout or {}) do
            if GetHashKey(weapon.name) == weaponHash then
                return {name = weapon.name, label = weapon.label, metadata = {ammo = weapon.ammo, components = weapon.components}}
            end
        end
    end

    return nil
end

P7H.Inventory.Disarm = function(state)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
end

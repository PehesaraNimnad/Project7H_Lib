if (Config.Appearance == 'auto' and not checkResource('qs-appearance')) or (Config.Appearance ~= 'auto' and Config.Appearance ~= 'qs-appearance') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Appearance] Loaded: qs-appearance')
end

P7H.Appearance = {}

P7H.Appearance.FetchCurrentSkin = function()
    return exports['qs-appearance']:getPedAppearance(cache.ped)
end

P7H.Appearance.FetchDatabaseSkin = function()
    local databaseSkin = lib.callback.await('qs-appearance:server:getAppearance', false)

    if Config.Debug then
        lib.print.info('[Appearance] Fetched database skin:', databaseSkin)
    end

    return databaseSkin
end

P7H.Appearance.ConvertSkinFormat = function(skinData)
    if not skinData or type(skinData) ~= 'table' then
        lib.print.error('[Appearance] Skin data is nil or not a table!')
        return
    end

    return {
        components = {
            {component_id = 1, drawable = skin.mask_1 or 0, texture = skin.mask_2 or 0},
            {component_id = 3, drawable = skin.torso_1 or 0, texture = skin.torso_2 or 0},
            {component_id = 4, drawable = skin.pants_1 or 0, texture = skin.pants_2 or 0},
            {component_id = 5, drawable = skin.bags_1 or 0, texture = skin.bags_2 or 0},
            {component_id = 6, drawable = skin.shoes_1 or 0, texture = skin.shoes_2 or 0},
            {component_id = 7, drawable = skin.accessory_1 or 0, texture = skin.accessory_2 or 0},
            {component_id = 8, drawable = skin.tshirt_1 or 0, texture = skin.tshirt_2 or 0},
            {component_id = 9, drawable = skin.armor_1 or 0, texture = skin.armor_2 or 0},
            {component_id = 10, drawable = skin.decals_1 or 0, texture = skin.decals_2 or 0},
            {component_id = 11, drawable = skin.torso_1 or 0, texture = skin.torso_2 or 0},
        },
        props = {
            {prop_id = 0, drawable = skin.helmet_1 or -1, texture = skin.helmet_2 or 0},
            {prop_id = 1, drawable = skin.glasses_1 or -1, texture = skin.glasses_2 or 0},
            {prop_id = 2, drawable = skin.ears_1 or -1, texture = skin.ears_2 or 0},
            {prop_id = 6, drawable = skin.watches_1 or -1, texture = skin.watches_2 or 0},
            {prop_id = 7, drawable = skin.bracelets_1 or -1, texture = skin.bracelets_2 or 0}
        }
    }
end

P7H.Appearance.SetPlayerSkin = function(skinData)
    if not skinData then
        lib.print.error('[Appearance] Skin data is nil or empty!')
        return
    end

    if type(skinData) == 'string' then
        skinData = json.decode(skinData)
    end

    exports['qs-appearance']:setPlayerAppearance(skinData)

    if Config.Debug then
        lib.print.info('[Appearance] Set player skin:', skinData)
    end
end

P7H.Appearance.SetPlayerClothing = function(clothingData)
    if not clothingData then
        lib.print.error('[Appearance] Clothing data is nil or empty!')
        return
    end

    if type(clothingData) == 'string' then
        clothingData = json.decode(clothingData)
    end

    exports['qs-appearance']:setPedComponents(cache.ped, clothingData.components)
    exports['qs-appearance']:setPedProps(cache.ped, clothingData.props)

    if Config.Debug then
        lib.print.info('[Appearance] Set player clothing:', clothingData)
    end
end

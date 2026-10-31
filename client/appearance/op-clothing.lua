if (Config.Appearance == 'auto' and not checkResource('op-clothing')) or (Config.Appearance ~= 'auto' and Config.Appearance ~= 'op-clothing') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Appearance] Loaded: op-clothing')
end

P7H.Appearance = {}

P7H.Appearance.FetchCurrentSkin = function()
    return exports['op-clothing']:GetAppearance()
end

P7H.Appearance.FetchDatabaseSkin = function()
    local databaseSkin = exports['op-clothing']:GetAppearance()

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
            {component_id = 1, drawable = skinData.mask_1 or 0, texture = skinData.mask_2 or 0},
            {component_id = 3, drawable = skinData.arms or 0, texture = skinData.arms_2 or 0},
            {component_id = 4, drawable = skinData.pants_1 or 0, texture = skinData.pants_2 or 0},
            {component_id = 5, drawable = skinData.bags_1 or 0, texture = skinData.bags_2 or 0},
            {component_id = 6, drawable = skinData.shoes_1 or 0, texture = skinData.shoes_2 or 0},
            {component_id = 7, drawable = skinData.chain_1 or 0, texture = skinData.chain_2 or 0},
            {component_id = 8, drawable = skinData.tshirt_1 or 0, texture = skinData.tshirt_2 or 0},
            {component_id = 9, drawable = skinData.bproof_1 or 0, texture = skinData.bproof_2 or 0},
            {component_id = 10, drawable = skinData.decals_1 or 0, texture = skinData.decals_2 or 0},
            {component_id = 11, drawable = skinData.torso_1 or 0, texture = skinData.torso_2 or 0},
        },
        props = {
            {prop_id = 0, drawable = skinData.helmet_1 or -1, texture = skinData.helmet_2 or 0},
            {prop_id = 1, drawable = skinData.glasses_1 or -1, texture = skinData.glasses_2 or 0},
            {prop_id = 2, drawable = skinData.ears_1 or -1, texture = skinData.ears_2 or 0},
            {prop_id = 6, drawable = skinData.watches_1 or -1, texture = skinData.watches_2 or 0},
            {prop_id = 7, drawable = skinData.bracelets_1 or -1, texture = skinData.bracelets_2 or 0}
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

    exports['op-clothing']:SetAppearance(skinData)

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

    exports['op-clothing']:SetPlayerClothing(clothingData)

    if Config.Debug then
        lib.print.info('[Appearance] Set player clothing:', clothingData)
    end
end

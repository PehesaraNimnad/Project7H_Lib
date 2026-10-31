while not P7H do
    Citizen.Wait(0)
end

local SUPPORTED = { 'illenium-appearance', 'fivem-appearance', 'qb-clothing' }

local function pick()
    for i = 1, #SUPPORTED do
        if GetResourceState(SUPPORTED[i]) == 'started' then return SUPPORTED[i] end
    end
    return 'none'
end

P7H.Appearance = P7H.Appearance or {}

P7H.Appearance.Name = pick

P7H.Appearance.ApplyToPed = function(ped, skin)
    local which = pick()
    if which == 'illenium-appearance' or which == 'fivem-appearance' then
        pcall(function() exports[which]:setPedAppearance(ped, skin) end)
    elseif which == 'qb-clothing' then
        TriggerEvent('qb-clothing:client:loadPlayerClothing', skin, ped)
    else
        SetPedDefaultComponentVariation(ped)
    end
end

P7H.Appearance.OpenCreator = function()
    local which = pick()
    if which == 'fivem-appearance' then
        exports['fivem-appearance']:startPlayerCustomization(function(look)
            if look then TriggerServerEvent('fivem-appearance:save', look) end
        end, { ped = true, headBlend = true, faceFeatures = true, headOverlays = true, components = true, props = true })
    elseif which ~= 'none' then
        TriggerEvent('qb-clothes:client:CreateFirstCharacter')
    end
end

--- Saves what the player's ped wears right now as their outfit (after a script changed a piece).
P7H.Appearance.SaveCurrent = function()
    local which = pick()
    if which ~= 'illenium-appearance' and which ~= 'fivem-appearance' then return false end
    local ok, look = pcall(function() return exports[which]:getPedAppearance(cache.ped) end)
    if not ok or not look then return false end
    TriggerServerEvent(which == 'illenium-appearance' and 'illenium-appearance:server:saveAppearance' or 'fivem-appearance:save', look)
    return true
end

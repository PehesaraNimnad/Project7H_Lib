while not P7H do
    Citizen.Wait(0)
end

local SUPPORTED = { 'qbx_properties', 'ps-housing', 'qb-apartments', 'qb-houses' }

local function pick()
    local wanted = Config.Housing or 'auto'
    if wanted ~= 'auto' then return GetResourceState(wanted) == 'started' and wanted or 'none' end
    for i = 1, #SUPPORTED do
        if GetResourceState(SUPPORTED[i]) == 'started' then return SUPPORTED[i] end
    end
    return 'none'
end

P7H.Housing = {}

P7H.Housing.Name = pick

P7H.Housing.OpenApartmentPicker = function(citizenid)
    local which = pick()
    if which == 'none' or which == 'qb-houses' then return false end
    if which == 'qbx_properties' then
        P7H.Framework.TriggerPlayerLoaded()
    else
        TriggerEvent('apartments:client:setupSpawnUI', { citizenid = citizenid })
    end
    return true
end

P7H.Housing.SelectApartment = function(apartment)
    if pick() == 'qbx_properties' then
        TriggerServerEvent('qbx_properties:server:apartmentSelect', apartment.index)
    else
        TriggerServerEvent('apartments:server:CreateApartment', apartment.id, apartment.label, true)
    end
end

P7H.Housing.Enter = function(property)
    if property.house then
        TriggerEvent('qb-houses:client:enterOwnedHouse', property.house)
        return
    end
    local c = property.coords
    if not c then return end
    SetEntityCoords(cache.ped, c.x, c.y, c.z, false, false, false, false)
    SetEntityHeading(cache.ped, c.w or 0.0)
end

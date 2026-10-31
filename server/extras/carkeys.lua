while not P7H do
    Citizen.Wait(0)
end

---Server side keys (the client side is P7H.CarKeys in client/carkeys). Use it right after spawning a vehicle on the server.
P7H.ServerKeys = P7H.ServerKeys or {}

local function started(name) return GetResourceState(name) == 'started' end

---@param src number
---@param vehicle number entity
---@param plate? string
---@return boolean
P7H.ServerKeys.Give = function(src, vehicle, plate)
    plate = plate or (vehicle and DoesEntityExist(vehicle) and GetVehicleNumberPlateText(vehicle))
    if started('Project07_CarKeys') then
        -- the plate first: right after a server spawn the entity still reports its old plate
        return pcall(function() return exports.Project07_CarKeys:GiveKeys(src, plate or vehicle) end)
    elseif started('qbx_vehiclekeys') then
        return pcall(function() return exports.qbx_vehiclekeys:GiveKeys(src, vehicle) end)
    elseif started('qb-vehiclekeys') then
        TriggerClientEvent('vehiclekeys:client:SetOwner', src, plate)
        return true
    elseif started('wasabi_carlock') then
        return pcall(function() return exports.wasabi_carlock:GiveKey(src, plate) end)
    end
    TriggerClientEvent('vehiclekeys:client:SetOwner', src, plate)
    return true
end

---A key left in the ignition goes back to the player (before a car is stored in a garage).
P7H.ServerKeys.Eject = function(plate, src)
    if not started('Project07_CarKeys') then return false end
    local ok, res = pcall(function() return exports.Project07_CarKeys:EjectKey(plate, src) end)
    return ok and res
end

---Lock or unlock (2 = locked, 1 = open).
P7H.ServerKeys.SetLocked = function(vehicle, locked)
    if started('Project07_CarKeys') then
        return pcall(function() return exports.Project07_CarKeys:SetLockState(vehicle, locked) end)
    end
    SetVehicleDoorsLocked(vehicle, locked and 2 or 1)
    return true
end

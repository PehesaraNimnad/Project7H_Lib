while not P7H do
    Citizen.Wait(1)
end

P7H.Setup = {}
P7H.Setup.InSetup = false

P7H.Setup.Point = function()
    if P7H.Setup.InSetup then
        return
    end

    AddTextEntry("P7HHelpNotification", 'Press ~INPUT_ATTACK~ to select point\nPress ~INPUT_VEH_DUCK~ to cancel')
    local currentCoords = nil
    P7H.Setup.InSetup = true
    Citizen.CreateThread(function()
        while P7H.Setup.InSetup do
            Citizen.Wait(0)
            local hit, entityHit, coords, _, _ = lib.raycast.fromCamera(511, 4, 15.0)
            if hit and hit ~= 0 then
                currentCoords = coords
            end
        end
    end)
    Citizen.CreateThread(function()
        while P7H.Setup.InSetup do
            Citizen.Wait(0)
            DisableControlAction(0, 24, true)
            if currentCoords then
                DisplayHelpTextThisFrame("P7HHelpNotification", false)
                DrawMarker(
                    28, currentCoords.x, currentCoords.y, currentCoords.z,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    0.4, 0.4, 0.4,
                    255, 0, 0, 150,
                    false, false, false, false
                )
                if IsControlPressed(0, 24) or IsDisabledControlPressed(0, 24) then
                    P7H.Setup.InSetup = false
                    lib.setClipboard(('vec3(%.2f, %.2f, %.2f),'):format(currentCoords.x, currentCoords.y, currentCoords.z))
                    P7H.Notify.ShowNotify('Point coords has been copied to your clipboard!', 'success')
                end
                if IsControlPressed(0, 73) then
                    P7H.Setup.InSetup = false
                    P7H.Notify.ShowNotify('Point setup has been cancelled!', 'error')
                end
            end
        end
    end)
end

P7H.Setup.Ped = function()
    if P7H.Setup.InSetup then
        return
    end

    AddTextEntry("P7HHelpNotification", 'Press ~INPUT_ATTACK~ to select point\nPress ~INPUT_CELLPHONE_LEFT~/~INPUT_CELLPHONE_RIGHT~ to rotate ped\nPress ~INPUT_VEH_DUCK~ to cancel')
    local pedModel = lib.requestModel('mp_m_freemode_01')
    local offset = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 1.0, 0.1)
    local currentPed = CreatePed(4, pedModel, offset, 0.0, false, true)
    SetEntityAlpha(currentPed, 200)
    FreezeEntityPosition(currentPed, true)
    SetEntityInvincible(currentPed, true)
    SetEntityCollision(currentPed, false, false)
    SetBlockingOfNonTemporaryEvents(currentPed, true)

    local currentCoords = nil
    P7H.Setup.InSetup = true
    Citizen.CreateThread(function()
        while P7H.Setup.InSetup do
            Citizen.Wait(0)
            local hit, entityHit, coords, _, _ = lib.raycast.fromCamera(511, 4, 15.0)
            if hit and hit ~= 0 then
                currentCoords = coords
            end
        end
    end)
    Citizen.CreateThread(function()
        while P7H.Setup.InSetup do
            Citizen.Wait(0)
            DisableControlAction(0, 24, true)
            if currentCoords then
                DisplayHelpTextThisFrame("P7HHelpNotification", false)
                SetEntityCoordsNoOffset(currentPed, currentCoords.x, currentCoords.y, currentCoords.z + 1.0, true, true, true)
                DrawMarker(
                    28, currentCoords.x, currentCoords.y, currentCoords.z,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    0.25, 0.25, 0.25,
                    255, 0, 0, 150,
                    false, false, false, false
                )
                if IsControlPressed(0, 24) or IsDisabledControlPressed(0, 24) then
                    P7H.Setup.InSetup = false
                    lib.setClipboard(('vec4(%.2f, %.2f, %.2f, %.2f),'):format(currentCoords.x, currentCoords.y, currentCoords.z + 1.0, GetEntityHeading(currentPed)))
                    P7H.Notify.ShowNotify('Ped coords has been copied to your clipboard!', 'success')
                    DeletePed(currentPed)
                end
                if IsControlPressed(0, 174) or IsDisabledControlPressed(0, 174) then
                    SetEntityHeading(currentPed, GetEntityHeading(currentPed) + 1.0)
                end
                if IsControlPressed(0, 175) or IsDisabledControlPressed(0, 175) then
                    SetEntityHeading(currentPed, GetEntityHeading(currentPed) - 1.0)
                end
                if IsControlPressed(0, 73) then
                    P7H.Setup.InSetup = false
                    DeletePed(currentPed)
                    P7H.Notify.ShowNotify('Ped setup has been cancelled!', 'error')
                end
            end
        end
    end)
end

P7H.Setup.Prop = function(propModel)
    if P7H.Setup.InSetup or not propModel then
        return
    end

    AddTextEntry("P7HHelpNotification", 'Press ~INPUT_ATTACK~ to confirm\nPress ~INPUT_CELLPHONE_LEFT~/~INPUT_CELLPHONE_RIGHT~ to rotate Z\nPress ~INPUT_CELLPHONE_UP~/~INPUT_CELLPHONE_DOWN~ to rotate X\nPress ~INPUT_VEH_DUCK~ to cancel')
    propModel = lib.requestModel(propModel)
    local offset = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 1.0, 0.1)
    local currentProp = CreateObject(propModel, offset, false, true, true)
    SetEntityAlpha(currentProp, 200)
    FreezeEntityPosition(currentProp, true)
    SetEntityCollision(currentProp, false, false)

    local currentCoords = nil
    P7H.Setup.InSetup = true
    Citizen.CreateThread(function()
        while P7H.Setup.InSetup do
            Citizen.Wait(0)
            local hit, entityHit, coords, _, _ = lib.raycast.fromCamera(511, 4, 15.0)
            if hit and hit ~= 0 then
                currentCoords = coords
            end
        end
    end)
    Citizen.CreateThread(function()
        while P7H.Setup.InSetup do
            Citizen.Wait(0)
            DisableControlAction(0, 24, true)
            if currentCoords then
                DisplayHelpTextThisFrame("P7HHelpNotification", false)
                SetEntityCoordsNoOffset(currentProp, currentCoords.x, currentCoords.y, currentCoords.z + 1.0, true, true, true)
                DrawMarker(
                    28, currentCoords.x, currentCoords.y, currentCoords.z,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    0.25, 0.25, 0.25,
                    255, 0, 0, 150,
                    false, false, false, false
                )
                if IsControlPressed(0, 24) or IsDisabledControlPressed(0, 24) then
                    P7H.Setup.InSetup = false
                    local rotation = GetEntityRotation(currentProp)
                    lib.setClipboard(('vec3(%.2f, %.2f, %.2f), vec3(%.2f, %.2f, %.2f)'):format(currentCoords.x, currentCoords.y, currentCoords.z, rotation.x, rotation.y, rotation.z))
                    P7H.Notify.ShowNotify('Prop coords has been copied to your clipboard!', 'success')
                    DeleteObject(currentProp)
                end
                if IsControlPressed(0, 174) or IsDisabledControlPressed(0, 174) then
                    local rotation = GetEntityRotation(currentProp, 2)
                    SetEntityRotation(currentProp, rotation.x, rotation.y, rotation.z + 1.0, 2, true)
                end
                if IsControlPressed(0, 175) or IsDisabledControlPressed(0, 175) then
                    local rotation = GetEntityRotation(currentProp, 2)
                    SetEntityRotation(currentProp, rotation.x, rotation.y, rotation.z - 1.0, 2, true)
                end
                if IsControlPressed(0, 172) or IsDisabledControlPressed(0, 172) then
                    local rotation = GetEntityRotation(currentProp, 2)
                    SetEntityRotation(currentProp, rotation.x - 1.0, rotation.y, rotation.z, 2, true)
                end
                if IsControlPressed(0, 173) or IsDisabledControlPressed(0, 174) then
                    local rotation = GetEntityRotation(currentProp, 2)
                    SetEntityRotation(currentProp, rotation.x + 1.0, rotation.y, rotation.z, 2, true)
                end
                if IsControlPressed(0, 73) then
                    P7H.Setup.InSetup = false
                    DeleteObject(currentProp)
                    P7H.Notify.ShowNotify('Prop setup has been cancelled!', 'error')
                end
            end
        end
    end)
end

RegisterNetEvent('Project7H_Lib/client/setup/start', function(setupType)
    if setupType == 'ped' then
        P7H.Setup.Ped()
    elseif setupType == 'point' then
        P7H.Setup.Point()
    elseif setupType == 'prop' then
        local input = lib.inputDialog('Prop Setup', {
            { type = 'input', label = 'Prop Model', description = 'Enter the prop model name (e.g., prop_barrel_02a)', required = true },
        })

        P7H.Setup.Prop(input[1])
    else
        P7H.Notify.ShowNotify('Invalid setup type!', 'error')
    end
end)

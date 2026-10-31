while not P7H do
    Citizen.Wait(0)
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(data)
    if not data.coords then
        data.coords = GetEntityCoords(cache.ped)
    end

    data.street = GetStreetNameFromHashKey(GetStreetNameAtCoord(data.coords.x, data.coords.y, data.coords.z))
    TriggerServerEvent('Project7H_Lib/server/dispatch/sendAlert', data)
end

RegisterNetEvent('Project7H_Lib/client/dispatch/glxsRelay', function(alertType, coords, context)
    TriggerServerEvent('glxs-dispatch:server:SendAlert', alertType, coords, context)
end)

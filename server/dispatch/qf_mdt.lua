if (Config.Dispatch == 'auto' and not checkResource('qf_mdt')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'qf_mdt') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: qf_mdt')
end

P7H.Dispatch = {}

P7H.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)
    local color = data.color or {255, 255, 255}

    TriggerClientEvent('qf_mdt/addDispatchAlert', -1, data.title, data.title, data.code, color, data.maxOfficers)
end

RegisterNetEvent('Project7H_Lib/server/dispatch/sendAlert', function(data)
    local src = source
    data = P7HDispatchGuard(src, data)
    if data then P7H.Dispatch.SendAlert(src, data) end
end)

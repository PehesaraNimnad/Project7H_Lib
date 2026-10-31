P7H = {}

P7H.Config = Config

function checkResource(resourceName)
    local state = GetResourceState(resourceName)
    return state ~= 'missing' and state ~= 'unknown'
end

exports('GetLib', function() return P7H end)

lib.addCommand('setup', {
    help = 'Setup ped or point',
    params = {
        {
            name = 'type',
            help = 'Type of setup (ped/point/prop)',
            type = 'string',
        }
    },
    restricted = 'group.admin',
}, function(source, args, raw)
    local _source = source
    TriggerClientEvent('Project7H_Lib/client/setup/start', _source, args.type)
end)

RegisterNetEvent('Project7H_Lib/server/removeItem', function(itemName, amount, metadata)
    local _source = source
    if not itemName or type(itemName) ~= 'string' then return end
    if not amount or type(amount) ~= 'number' then amount = 1 end

    if P7H.Inventory then
        P7H.Inventory.RemoveItem(_source, itemName, amount, metadata)
    end
end)

lib.callback.register('Project7H_Lib/server/getPlayerSkin', function(source)
    local _source = source
    local identifier = P7H.Framework.GetUniqueId(_source)
    if GetResourceState('tgiann-clothing') == 'started' then
        local result = MySQL.query.await('SELECT * FROM tgiann_skin WHERE citizenid = ?', { identifier })
        if result and result[1] then
            return json.decode(result[1].skin)
        end
    elseif GetResourceState('rcore_clothing') == 'started' then
        local identifier = P7H.Framework.GetUniqueId(_source)
        return exports["rcore_clothing"]:getSkinByIdentifier(identifier)
    elseif GetResourceState('es_extended') == 'started' then
        local row = MySQL.single.await('SELECT skin FROM users WHERE identifier = ?', {
            identifier
        })
        return row and json.decode(row.skin) or nil
    elseif GetResourceState('qb-core') == 'started' or GetResourceState('qbx_core') == 'started' then
        local row = MySQL.single.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = 1', {
            identifier
        })
        return row and json.decode(row.skin) or nil
    end

    return nil
end)

P7H = {}

P7H.Config = Config

function checkResource(resourceName)
    local state = GetResourceState(resourceName)
    return state ~= 'missing' and state ~= 'unknown'
end

exports('GetLib', function()
    return P7H
end)

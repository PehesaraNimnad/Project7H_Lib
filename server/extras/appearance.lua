while not P7H do
    Citizen.Wait(0)
end

P7H.Appearance = P7H.Appearance or {}

P7H.Appearance.GetSkin = function(citizenid)
    local ok, row = pcall(MySQL.single.await, 'SELECT skin, model FROM playerskins WHERE citizenid = ? AND active = 1 LIMIT 1', { citizenid })
    if not ok or not row then return end
    local skin = row.skin
    if type(skin) == 'string' then
        local okDecode, decoded = pcall(json.decode, skin)
        skin = okDecode and decoded or nil
    end
    return skin, row.model
end

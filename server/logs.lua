while not P7H do Citizen.Wait(0) end

P7H.Logs = {}

P7H.Logs.Send = function(playerId, title, message, webhook)
    Citizen.CreateThread(function()
        if not Config.Logs then return end
        if not message or not webhook then
            lib.print.error(('No message or webhook provided for logging [%s]'):format(GetInvokingResource() or cache.resource))
            return
        end
        local steamName, steamHex, discordId, license = 'Unknown', 'Unknown', 'Unknown', P7H.Framework.GetUniqueId(playerId) or 'Unknown'
        if playerId then
            steamName = GetPlayerName(playerId) or 'Unknown'
            local identifiers = GetPlayerIdentifiers(playerId)
            for i = 1, #identifiers do
                if string.find(identifiers[i], 'steam:') then
                    steamHex = identifiers[i]
                elseif string.find(identifiers[i], 'discord:') then
                    discordId = string.gsub(identifiers[i], 'discord:', '')
                end
            end
        end

        message = message..'\n\n-----------\n**Source Info**\nID: '..(playerId or 'Server')..'\nSteam Name: '..steamName..'\nSteam HEX: '..steamHex..'\nDiscord: <@'..discordId..'>\nLicense: '..license
        local embedData = { {
            ['title'] = title or GetInvokingResource(),
            ['color'] = 14423100,
            ['footer'] = {
                ['text'] = ("%s | Project7H_Lib | " .. os.date()):format(title or GetInvokingResource()),
                ['icon_url'] = "https://r2.fivemanage.com/xlufCGKYLtGfU8IBmjOL9/LOGO3.png"
            },
            ['description'] = message,
            ['author'] = {
                ["name"] = "Project7H_Lib",
                ['icon_url'] = "https://r2.fivemanage.com/xlufCGKYLtGfU8IBmjOL9/LOGO3.png"
            }
        } }
        PerformHttpRequest(webhook, nil, 'POST', json.encode({
            username = 'Project7H_Lib',
            embeds = embedData
        }), {
            ['Content-Type'] = 'application/json'
        })
    end)
end

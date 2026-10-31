if (Config.Phone == 'auto' and not checkResource('sd-phone')) or (Config.Phone ~= 'auto' and Config.Phone ~= 'sd-phone') then
    return
end

while not P7H do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Phone] Loaded: sd-phone')
end

local phone = exports['sd-phone']

P7H.Phone = {}
P7H.Phone.Name = 'sd-phone'

P7H.Phone.GetNumber = function(playerId)
    return phone:getPhoneNumber(playerId)
end

P7H.Phone.GetNumberByIdentifier = function(citizenid)
    return phone:getPhoneNumberByIdentifier(citizenid, true)
end

P7H.Phone.GetIdentifierByNumber = function(number)
    return phone:getIdentifierByNumber(number)
end

P7H.Phone.GetSourceByNumber = function(number)
    return phone:getSourceByNumber(number)
end

P7H.Phone.HasPhone = function(playerId)
    return phone:hasPhone(playerId) ~= nil
end

P7H.Phone.HasService = function(playerId, capability)
    return phone:hasService(playerId, capability)
end

P7H.Phone.Notify = function(playerId, data)
    return phone:notify(playerId, data)
end

P7H.Phone.NotifyNumber = function(number, data)
    return phone:notifyNumber(number, data)
end

P7H.Phone.EmergencyAlert = function(playerId, data)
    return phone:emergencyAlert(playerId, data)
end

P7H.Phone.SendMessage = function(senderNumber, senderName, targetNumber, body, opts)
    return phone:sendSystemMessage(senderNumber, senderName, targetNumber, body, opts)
end

P7H.Phone.SendMail = function(mail)
    return phone:sendMail(mail)
end

P7H.Phone.AddBankTransaction = function(citizenid, data)
    return phone:addBankTransaction(citizenid, data)
end

P7H.Phone.IsInCall = function(playerId)
    return phone:isInCall(playerId)
end

P7H.Phone.EndCall = function(playerId)
    return phone:endCallFor(playerId)
end

P7H.Phone.StartGroupCall = function(playerId, targets, displayName, displayNumber)
    return phone:startGroupCall(playerId, targets, displayName, displayNumber)
end

P7H.Phone.MessageCompany = function(playerId, payload)
    return phone:messageCompany(playerId, payload)
end

P7H.Phone.PostArticle = function(article)
    return phone:postArticle(article)
end

P7H.Phone.CreateDocument = function(playerId, opts)
    return phone:createDocument(playerId, opts)
end

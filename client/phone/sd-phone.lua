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

P7H.Phone.ToggleDisabled = function(state)
    phone:setDisabled(state == true)
end

P7H.Phone.IsDisabled = function()
    return phone:isDisabled()
end

P7H.Phone.IsOpen = function()
    return phone:isOpen()
end

P7H.Phone.IsLocked = function()
    return phone:isLocked()
end

P7H.Phone.Open = function()
    phone:open()
end

P7H.Phone.Close = function()
    phone:close()
end

P7H.Phone.OpenApp = function(appId, link)
    return phone:openApp(appId, link)
end

P7H.Phone.Notify = function(data)
    phone:showNotification(data)
end

P7H.Phone.HasService = function(capability)
    return phone:hasService(capability)
end

P7H.Phone.GetServiceBars = function()
    return phone:getServiceBars()
end

P7H.Phone.IsOnWifi = function()
    return phone:isOnWifi()
end

P7H.Phone.GetWifi = function()
    return phone:getWifiNetwork()
end

P7H.Phone.IsBluetoothConnected = function(deviceId)
    return phone:isBluetoothConnected(deviceId)
end

P7H.Phone.AddCustomApp = function(app)
    return phone:addCustomApp(app)
end

P7H.Phone.RemoveCustomApp = function(identifier)
    return phone:removeCustomApp(identifier)
end

P7H.Phone.SendCustomAppMessage = function(identifier, message)
    return phone:sendCustomAppMessage(identifier, message)
end

P7H.Phone.ShowWidget = function(appId, widgetId, data, onAction)
    return phone:showLockscreenWidget(appId, widgetId, data, onAction)
end

P7H.Phone.HideWidget = function(appId, widgetId)
    return phone:hideLockscreenWidget(appId, widgetId)
end

P7H.Phone.GetActiveGroup = function()
    return phone:getActiveGroup()
end

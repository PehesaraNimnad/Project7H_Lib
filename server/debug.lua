while not P7H do Citizen.Wait(0) end

P7H.Debug = function(message)
    if Config.Debug then
        local invoker = GetInvokingResource() or GetCurrentResourceName()
        lib.print.info(('[%s] %s'):format(invoker, message))
    end
end

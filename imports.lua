P7H = exports['Project7H_Lib']:GetLib()

-- UI kit: the dialogs and progress bars wait here, in the calling resource, for the answer from the Lib
if not IsDuplicityVersion() and P7H and P7H.UI then
    local Lib = exports['Project7H_Lib']

    local function await(start)
        local p = promise.new()
        start(function(result) p:resolve(result) end)
        return Citizen.Await(p)
    end

    P7H.UI.InputDialog = function(heading, rows, options)
        return await(function(done) Lib:InputDialog(heading, rows, options, done) end)
    end
    P7H.UI.AlertDialog = function(data)
        return await(function(done) Lib:AlertDialog(data, done) end)
    end
    P7H.UI.ProgressBar = function(data)
        return await(function(done) Lib:ProgressBar(data, done) end) == true
    end
    P7H.UI.ProgressCircle = function(data)
        return await(function(done) Lib:ProgressCircle(data, done) end) == true
    end
end

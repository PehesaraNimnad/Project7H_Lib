while not P7H do
    Citizen.Wait(0)
end

local SUPPORTED = { 'Project7H_Weather', 'Renewed-Weathersync', 'qb-weathersync', 'cd_easytime' }
local SNOW = { XMAS = true, SNOWLIGHT = true, BLIZZARD = true, SNOW = true }
local paused = false

local function pick()
    local wanted = Config.Weather or 'auto'
    if wanted ~= 'auto' then return GetResourceState(wanted) == 'started' and wanted or 'none' end
    for i = 1, #SUPPORTED do
        if GetResourceState(SUPPORTED[i]) == 'started' then return SUPPORTED[i] end
    end
    return 'none'
end

local function usesStatebag(which)
    return which == 'Renewed-Weathersync' or which == 'Project7H_Weather'
end

P7H.Weather = {}

P7H.Weather.Name = pick

P7H.Weather.Pause = function(on, weather)
    local which = pick()
    if usesStatebag(which) and on and weather then LocalPlayer.state.playerWeather = weather end
    if paused == on then return end
    paused = on
    if usesStatebag(which) then
        LocalPlayer.state.syncWeather = not on
    elseif which == 'qb-weathersync' then
        TriggerEvent(on and 'qb-weathersync:client:DisableSync' or 'qb-weathersync:client:EnableSync')
    elseif which == 'cd_easytime' then
        TriggerEvent('cd_easytime:PauseSync', on)
    end
    if not on then
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        NetworkClearClockTimeOverride()
        ForceSnowPass(false)
        SetForcePedFootstepsTracks(false)
        SetForceVehicleTrails(false)
    end
end

P7H.Weather.Set = function(weather)
    if usesStatebag(pick()) then LocalPlayer.state.playerWeather = weather end
end

P7H.Weather.Show = function(weather, hour, minute)
    P7H.Weather.Set(weather)
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypeNowPersist(weather)
    SetOverrideWeather(weather)
    local snow = SNOW[weather] == true
    ForceSnowPass(snow)
    SetForcePedFootstepsTracks(snow)
    SetForceVehicleTrails(snow)
    if hour then NetworkOverrideClockTime(hour, minute or 0, 0) end
end

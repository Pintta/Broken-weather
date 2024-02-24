local CurrentWeather = 'EXTRASUNNY'
local baseTime = 8
local timeOffset = 0
local freezeTime = false
local blackout = false
local newWeatherTimer = 60

local function nextWeatherStage()
    if CurrentWeather == "CLEAR" or CurrentWeather == "CLOUDS" or CurrentWeather == "EXTRASUNNY" then
        CurrentWeather = (math.random(1, 5) > 2) and "CLEARING" or "OVERCAST"
    elseif CurrentWeather == "CLEARING" or CurrentWeather == "OVERCAST" then
        local new = math.random(1, 6)
        if new == 1 then
            CurrentWeather = (CurrentWeather == "CLEARING") and "FOGGY" or "RAIN"
        elseif new == 2 then
            CurrentWeather = "CLOUDS"
        elseif new == 3 then
            CurrentWeather = "CLEAR"
        elseif new == 4 then
            CurrentWeather = "EXTRASUNNY"
        elseif new == 5 then
            CurrentWeather = "SMOG"
        else
            CurrentWeather = "FOGGY"
        end
    elseif CurrentWeather == "THUNDER" or CurrentWeather == "RAIN" then
        CurrentWeather = "CLEARING"
    elseif CurrentWeather == "SMOG" or CurrentWeather == "FOGGY" then
        CurrentWeather = "CLEAR"
    else
        CurrentWeather = "CLEAR"
    end
    TriggerEvent("Broken-weather:server:RequestStateSync")
end

local function setWeather(weather)
    local validWeatherType = false
    local Saatyypit = {
        'EXTRASUNNY',
        'CLEAR',
        'NEUTRAL',
        'SMOG',
        'FOGGY',
        'OVERCAST',
        'CLOUDS',
        'CLEARING',
        'RAIN',
        'THUNDER',
        'SNOW',
        'BLIZZARD',
        'SNOWLIGHT',
        'XMAS',
        'HALLOWEEN',
    }
    for _, weatherType in pairs(Saatyypit) do
        if weatherType == string.upper(weather) then
            validWeatherType = true
        end
    end
    if not validWeatherType then
        return false
    end
    CurrentWeather = string.upper(weather)
    newWeatherTimer = 60
    TriggerEvent('Broken-weather:server:RequestStateSync')
    return true
end

local function setBlackout(state)
    if state == nil then
        state = not blackout
    end
    if state then
        blackout = true
    else
        blackout = false
    end
    TriggerEvent('Broken-weather:server:RequestStateSync')
    return blackout
end

local function setDynamicWeather(state)
    local DW = true
    if state == nil then
        state = not DW
    end
    if state then
        DW = true
    else
        DW = false
    end
    TriggerEvent('Broken-weather:server:RequestStateSync')
    return DW
end

RegisterNetEvent('Broken-weather:server:RequestStateSync', function()
    TriggerClientEvent('Broken-weather:client:SyncWeather', -1, CurrentWeather, blackout)
    TriggerClientEvent('Broken-weather:client:SyncTime', -1, baseTime, timeOffset, freezeTime)
end)

CreateThread(function()
    local previous = 0
    while true do
        Wait(0)
        local newBaseTime = os.time(os.date("!*t")) / 2 + 360
        if (newBaseTime % 60) ~= previous then
            previous = newBaseTime % 60
            if freezeTime then
                timeOffset = timeOffset + baseTime - newBaseTime
            end
            baseTime = newBaseTime
        end
    end
end)

CreateThread(function()
    while true do
        Wait(2000)
        TriggerClientEvent('Broken-weather:client:SyncTime', -1, baseTime, timeOffset, freezeTime)
    end
end)

CreateThread(function()
    while true do
        Wait(300000)
        TriggerClientEvent('Broken-weather:client:SyncWeather', -1, CurrentWeather, blackout)
    end
end)

CreateThread(function()
    while true do
        newWeatherTimer = newWeatherTimer - 1
        local NextWeather = (1000 * 60) * 60 -- Every 1 hour change weather (HC Roleplay) 1000 milliseconds x 60 seconds x 60 minutes math.
        Wait(NextWeather)
        if newWeatherTimer == 0 then
            nextWeatherStage()
            newWeatherTimer = 60
        end
    end
end)

exports('nextWeatherStage', nextWeatherStage)
exports('setWeather', setWeather)
exports('setBlackout', setBlackout)
exports('setDynamicWeather', setDynamicWeather)

exports('getBlackoutState', function()
    return blackout
end)

exports('getWeatherState', function()
    return CurrentWeather
end)

exports('getDynamicWeather', function()
    local DW = true
    return DW
end)

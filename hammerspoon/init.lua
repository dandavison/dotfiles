-- require("hs.inspect")
require("hs.ipc")
require("hs.eventtap")
require("hs.notify")

Logger = hs.logger.new('dan', "debug")


-- https://www.hammerspoon.org/docs/hs.keycodes.html#map

-- https://github.com/alacritty/alacritty/issues/862#issuecomment-616873890
hs.hotkey.bind({ "cmd" }, "'", function()
    local alacritty = hs.application.find('alacritty')
    if alacritty:isFrontmost() then
        alacritty:hide()
    else
        hs.application.launchOrFocus("/Applications/Alacritty.app")
    end
end)

hs.hotkey.bind({ "cmd" }, "space", function()
    hs.application.launchOrFocus("/Applications/Wormhole.app")
end)

hs.hotkey.bind({}, "f13", function()
    hs.application.launchOrFocus("/Applications/Wormhole.app")
end)

hs.hotkey.bind({ "cmd", "control" }, "left", function()
    hs.http.get("http://wormhole:7117/previous-project/", nil)
end)

hs.hotkey.bind({ "cmd", "control" }, "right", function()
    hs.http.get("http://wormhole:7117/previous-project/", nil)
end)


local fingerCount = 3
local swipeSensitivity = 20

local previousTouches = {}
local startTime = nil

local function printTable(t)
    for key, value in pairs(t) do
        print(key, value)
    end
end

Counter = 0

local logger = hs.logger.new('gesture', 'debug')

local function isSwipeLeft(touches)
    local totalDeltaX = 0
    for _, touch in ipairs(touches) do
        -- print("touch:")
        -- printTable(touch)
        -- logger.d("(prev_x, x) =", touch.previousNormalizedPosition.x, touch.normalizedPosition.x)
        local deltaX = touch.normalizedPosition.x - touch.previousNormalizedPosition.x
        totalDeltaX = totalDeltaX + deltaX
    end
    if math.abs(totalDeltaX) > 0.04 then
        logger.d("totaldeltaX", totalDeltaX)
        return true
    else
        return false
    end
end

Eventtap = hs.eventtap.new({ hs.eventtap.event.types.gesture }, function(event)
    local touches = event:getTouches()
    if #touches == 3 then
        print("event")
        -- print(hs.inspect(getmetatable(event)))
        local doit = isSwipeLeft(touches)
        -- logger.d("gesture event, #touches=", #touches, doit)
        if doit then
            Counter = Counter + 1
            hs.notify.new({
                title = string.format("Would switch [%d]", Counter),
                informativeText = "",
                autoWithdraw = true,
            }):send()
            -- hs.http.get("http://wormhole:7117/previous-project/", nil)
        end
    end
end)


Eventtap:start()

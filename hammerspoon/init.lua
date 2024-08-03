require("hs.ipc")
require("hs.eventtap")

local logger = hs.logger.new('dan', "verbose")


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
    logger.d("f13")
    hs.application.launchOrFocus("/Applications/Wormhole.app")
end)

hs.hotkey.bind({ "cmd", "control" }, "left", function()
    hs.http.get("http://wormhole:7117/previous-project/", nil)
end)

hs.hotkey.bind({ "cmd", "control" }, "right", function()
    hs.http.get("http://wormhole:7117/previous-project/", nil)
end)


logger.d("hello from logger")


local fingerCount = 3
local swipeSensitivity = 20

local previousTouches = {}
local startTime = nil

local function isSwipeLeft(touches)
    if #touches == fingerCount then
        local totalDeltaX = 0
        for _, touch in pairs(touches) do
            totalDeltaX = totalDeltaX + touch.deltaX
        end
        return totalDeltaX < -swipeSensitivity
    end
    return false
end

-- hs.http.get("http://wormhole:7117/previous-project/", nil)

local eventtap  = hs.eventtap.new({ hs.eventtap.event.types.gesture }, function(event)
    local touches = event:getTouches()
    if #touches == 3 then
        logger.d("gesture event, #touches=", #touches)
        hs.http.get("http://wormhole:7117/previous-project/", nil)
    end
end)

eventtap:start()

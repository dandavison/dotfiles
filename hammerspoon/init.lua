-- require("hs.inspect")
require("hs.ipc")
require("hs.eventtap")
require("hs.notify")


Logger = hs.logger.new('dan', "debug")


-- https://www.hammerspoon.org/docs/hs.keycodes.html#map
-- https://github.com/alacritty/alacritty/issues/862#issuecomment-616873890

local function terminal()
    local name = "Wezterm"

    local app = hs.application.find(name:lower())
    if app:isFrontmost() then
        app:hide()
    else
        hs.application.launchOrFocus("/Applications/" .. name .. ".app")
    end
end

local function wormholeSelect()
    hs.application.launchOrFocus("/Applications/Wormhole.app")
end


local function wormholePrevious()
    hs.http.get("http://wormhole:7117/previous-project/", nil)
end

local function wormholeNext()
    hs.http.get("http://wormhole:7117/next-project/", nil)
end

hs.hotkey.bind({}, "f16", terminal)
hs.hotkey.bind({}, "f13", wormholeSelect)
hs.hotkey.bind({ "cmd", "control" }, "left", wormholePrevious)
hs.hotkey.bind({ "cmd", "control" }, "right", wormholeNext)


local current_id, threshold
Swipe = hs.loadSpoon("Swipe")
Swipe:start(3, function(direction, distance, id)
    if id == current_id then
        Logger.d("distance", distance)
        if distance > threshold then
            threshold = math.huge
            if direction == "left" then
                wormholePrevious()
                -- hs.notify.new({
                --     title = "→→→→",
                --     informativeText = "",
                --     autoWithdraw = true,
                -- }):send()
            elseif direction == "right" then
                wormholeNext()
                -- hs.notify.new({
                --     title = "←←←←",
                --     informativeText = "",
                --     autoWithdraw = true,
                -- }):send()
            end
        end
    else
        current_id = id
        threshold = 0.05 -- swipe distance > % of trackpad
    end
end)

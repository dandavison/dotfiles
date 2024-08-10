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


local current_id, threshold
Swipe = hs.loadSpoon("Swipe")
Swipe:start(3, function(direction, distance, id)
    if id == current_id then
        Logger.d("distance", distance)
        if distance > threshold then
            threshold = math.huge
            if direction == "left" then
                hs.http.get("http://wormhole:7117/previous-project/", nil)
                -- hs.notify.new({
                --     title = "→→→→",
                --     informativeText = "",
                --     autoWithdraw = true,
                -- }):send()
            elseif direction == "right" then
                hs.http.get("http://wormhole:7117/previous-project/", nil)
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

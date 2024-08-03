require("hs.ipc")

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

hs.hotkey.bind({ "cmd", "control" }, "left", function()
    hs.http.get("http://wormhole:7117/previous-project/", nil)
end)

hs.hotkey.bind({ "cmd", "control" }, "right", function()
    hs.http.get("http://wormhole:7117/previous-project/", nil)
end)



-- require("hs.inspect")
require("hs.ipc")
require("hs.eventtap")
require("hs.notify")
hs.loadSpoon('EmmyLua')

Logger = hs.logger.new('dan', "debug")

-- Load wormhole module from wormhole repo
package.path = package.path .. ";/Users/dan/src/wormhole/hammerspoon/?.lua"
local wormhole = require("wormhole")

-- Terminal toggle (non-wormhole)
local function terminal()
    local app = hs.application.find("alacritty")
    if app then
        if app:isFrontmost() then
            app:hide()
        else
            app:activate()
        end
    else
        hs.application.launchOrFocus("/Applications/Alacritty.app")
    end
end

-- Project hotkey mappings (personal config)
local keymap = {
    [1] = "temporal",
    [2] = "api",
    [3] = "api-go",
    [4] = "bench-go",
    [5] = "saas-cicd",
    [6] = "saas-temporal",
    [7] = "sdk-python",
    [8] = "wormhole",
    [9] = "devenv",
    [0] = "temporal-all",
}

-- Bind wormhole project hotkeys
wormhole.bindProjectHotkeys(keymap)

-- Keybindings
hs.hotkey.bind({}, "f16", terminal)
hs.hotkey.bind({}, "f13", wormhole.select)
hs.hotkey.bind({ "cmd", "control" }, "left", wormhole.previous)
hs.hotkey.bind({ "cmd", "control" }, "right", wormhole.next)
hs.hotkey.bind({ "cmd", "control" }, ".", wormhole.pin)
hs.hotkey.bind({ "cmd", "alt" }, "k", wormhole.createHotkeyOverlay(keymap))
hs.hotkey.bind({ "cmd", "alt" }, "r", function()
    hs.reload()
end)

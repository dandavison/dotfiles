-- require("hs.inspect")
require("hs.ipc")
hs.loadSpoon('EmmyLua')

Logger = hs.logger.new('dan', "debug")

-- Load wormhole module from wormhole repo
package.path = package.path .. ";/Users/dan/src/wormhole/hammerspoon/?.lua"
local wormhole = require("wormhole")

-- Load tide module from tide repo
package.path = package.path .. ";/Users/dan/src/tide/hammerspoon/?.lua"
local tide = require("tide")

-- Terminal toggle
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

-- Editor toggle (f17). Pinned to VSCode rather than tracking the current
-- editor (`wormhole editor`): doing so correctly needs the running-name vs
-- launchable-name distinction (VSCode reports "Code" when running but launches
-- as "Visual Studio Code") that wormhole's editor.rs already encodes but the
-- hammerspoon module doesn't expose. Not worth duplicating here for now.
local function code()
    local app = hs.application.find("Code")
    if app then
        if app:isFrontmost() then
            app:hide()
        else
            app:activate()
        end
    else
        hs.application.launchOrFocus("/Applications/Visual Studio Code.app")
    end
end

-- Project hotkey mappings (personal config)
local keymap = {
    [0] = "projects",
    [1] = "temporal",
    [2] = "api",
    [3] = "api-go",
    [4] = "bench-go",
    [5] = "saas-cicd",
    [6] = "saas-temporal",
    [7] = "sdk-python",
    [8] = "wormhole",
    [9] = "devenv",
}

-- Keybindings
wormhole.bindKeys(keymap)
hs.hotkey.bind({}, "f16", terminal)
hs.hotkey.bind({}, "f17", code)

tide.bindKeys()

-- App launcher popup
hs.hotkey.bind({ "cmd" }, "x", function()
    tide.popup({ "display-popup", "-E", "-w", "60%", "-h", "70%", "-b", "rounded", "-T", "", tide.picker("f-open-app") })
end)
hs.hotkey.bind({ "cmd", "alt" }, "r", function()
    hs.reload()
end)
hs.alert.show("♻️", 0.5)


-- open "vscode://dandavison.vscode-etc/command?id=magit.status"

-- # Hammerspoon
-- hs.urlevent.openURL("vscode://dandavison.vscode-etc/command?id=magit.status")

-- require("hs.inspect")
require("hs.ipc")
hs.loadSpoon('EmmyLua')

Logger = hs.logger.new('dan', "debug")

-- Load wormhole module from wormhole repo
package.path = package.path .. ";/Users/dan/src/wormhole/hammerspoon/?.lua"
local wormhole = require("wormhole")

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

local popupTasks = {} -- retain tasks so GC doesn't drop the completion callback

-- tmux display-popup, focusing alacritty first if needed. When the popup is dismissed,
-- focus returns to the previously frontmost app, unless focus has been switched.
local function tmuxPopup(args)
    local prev = hs.application.frontmostApplication()
    local app = hs.application.find("alacritty")
    if not (app and app:isFrontmost()) then
        hs.application.launchOrFocus("/Applications/Alacritty.app")
    end
    local task
    task = hs.task.new(os.getenv("HOME") .. "/bin/tmux", function()
        popupTasks[task] = nil
        local front = hs.application.frontmostApplication()
        if prev
            and prev:bundleID() ~= "org.alacritty"
            and prev:isRunning()
            and front
            and front:bundleID() == "org.alacritty"
        then
            prev:activate()
        end
    end, args)
    popupTasks[task] = true
    task:start()
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

-- Full-screen scratch zsh popup (same as tmux M-Space)
hs.hotkey.bind({ "alt" }, "space", function()
    tmuxPopup({ "display-popup", "-d", "#{pane_current_path}", "-E", "-w", "100%", "-h", "100%", "-b", "rounded", "-T", "", "SKIP_XOLMIS=1 zsh" })
end)
-- App launcher popup
hs.hotkey.bind({ "cmd" }, "space", function()
    tmuxPopup({ "display-popup", "-E", "-w", "60%", "-h", "70%", "-b", "rounded", "-T", "", os.getenv("HOME") .. "/bin/f-open-app" })
end)
hs.hotkey.bind({ "cmd", "alt" }, "r", function()
    hs.reload()
end)
hs.alert.show("♻️", 0.5)


-- open "vscode://dandavison.vscode-etc/command?id=magit.status"

-- # Hammerspoon
-- hs.urlevent.openURL("vscode://dandavison.vscode-etc/command?id=magit.status")

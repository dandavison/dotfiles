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

-- Resolve tmux via a login shell (hs.execute(_, true)) so GUI-launched
-- Hammerspoon picks up Homebrew's PATH rather than launchd's minimal one.
local tmux = hs.execute("command -v tmux", true):gsub("%s+$", "")

local popupTasks = {} -- retain tasks so GC doesn't drop the completion callback

-- Alacritty, not tmux, must own the mouse while a popup is up. A popup is not a
-- pane: tmux forwards mouse events to the popup's program only if that program
-- asked for mouse mode and drops them otherwise (popup_key_cb), yet `mouse on`
-- still enables mouse reporting on the client -- so double-click would select
-- nothing. With mouse off the popup's own screen mode drives reporting, so a
-- plain shell gets native Alacritty selection while a TUI in the popup still
-- gets mouse. display-popup blocks the command queue until the popup is
-- dismissed, so the trailing set restores pane behavior on close.
local function withMouseOff(args)
    local argv = { "set", "-g", "mouse", "off", ";" }
    table.move(args, 1, #args, #argv + 1, argv)
    for _, arg in ipairs({ ";", "set", "-g", "mouse", "on" }) do
        argv[#argv + 1] = arg
    end
    return argv
end

-- tmux display-popup, focusing alacritty first if needed. When the popup is
-- dismissed, focus returns to the previously frontmost app, unless focus has
-- been switched or keepFocus is set (for popups whose action leaves you
-- somewhere in tmux).
local function tmuxPopup(args, keepFocus)
    local prev = hs.application.frontmostApplication()
    local app = hs.application.find("alacritty")
    if not (app and app:isFrontmost()) then
        hs.application.launchOrFocus("/Applications/Alacritty.app")
    end
    local task
    task = hs.task.new(tmux, function()
        popupTasks[task] = nil
        local front = hs.application.frontmostApplication()
        if not keepFocus
            and prev
            and prev:bundleID() ~= "org.alacritty"
            and prev:isRunning()
            and front
            and front:bundleID() == "org.alacritty"
        then
            prev:activate()
        end
    end, withMouseOff(args))
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

-- Full-screen scratch zsh popup
hs.hotkey.bind({ "alt" }, "space", function()
    tmuxPopup({ "display-popup", "-d", "#{pane_current_path}", "-E", "-w", "100%", "-h", "100%", "-b", "rounded", "-T", "", "SKIP_XOLMIS=1 zsh" })
end)
-- The pickers run under an interactive shell: a popup's shell is otherwise
-- non-interactive, so it would miss shell/env.sh, and fzf would fall back to
-- its own defaults rather than FZF_DEFAULT_OPTS.
local function picker(command)
    return "zsh -ic '" .. os.getenv("HOME") .. "/bin/" .. command .. "'"
end

-- App launcher popup
hs.hotkey.bind({ "cmd" }, "space", function()
    tmuxPopup({ "display-popup", "-E", "-w", "60%", "-h", "70%", "-b", "rounded", "-T", "", picker("f-open-app") })
end)
-- Project picker popups landing in one of the chosen project's tide views,
-- i.e. that view's tmux key in that project's window.
local function bindTideView(key, view)
    hs.hotkey.bind({ "cmd" }, key, function()
        tmuxPopup({ "display-popup", "-E", "-w", "60%", "-h", "70%", "-b", "rounded", "-T", "", picker("f-tide " .. view) }, true)
    end)
end

bindTideView("j", "files") -- M-j
bindTideView("m", "git")   -- M-l
hs.hotkey.bind({ "cmd", "alt" }, "r", function()
    hs.reload()
end)
hs.alert.show("♻️", 0.5)


-- open "vscode://dandavison.vscode-etc/command?id=magit.status"

-- # Hammerspoon
-- hs.urlevent.openURL("vscode://dandavison.vscode-etc/command?id=magit.status")

-- require("hs.inspect")
require("hs.ipc")
require("hs.eventtap")
require("hs.notify")
hs.loadSpoon('EmmyLua')

Logger = hs.logger.new('dan', "debug")


-- https://www.hammerspoon.org/docs/hs.keycodes.html#map
-- https://github.com/alacritty/alacritty/issues/862#issuecomment-616873890

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

local function wormholeSelect()
    local frontApp = hs.application.frontmostApplication()
    if frontApp and frontApp:name() == "Wormhole" then
        -- Already focused: toggle between current/available projects
        hs.eventtap.keyStroke({}, "tab")
    else
        hs.application.launchOrFocus("/Applications/Wormhole.app")
    end
end

local function wormholePrevious()
    hs.http.asyncGet("http://wormhole:7117/previous-project/", nil, function() end)
end

local function wormholeNext()
    hs.http.asyncGet("http://wormhole:7117/next-project/", nil, function() end)
end

local function wormholePin()
    hs.http.asyncPost("http://wormhole:7117/pin/", "", nil, function() end)
end

local keymap = {
    ["server"] = {
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
    },
}

local function getActiveWorkspace()
    local file = io.open("/tmp/ws", "r")
    if file then
        local content = file:read("*all")
        file:close()
        return content:match("^%s*(.-)%s*$")
    end
    return "server"
end

local function getRepos()
    local workspace = getActiveWorkspace()
    return keymap[workspace] or keymap["temporal"]
end

for i = 0, 9 do
    hs.hotkey.bind({ "cmd" }, tostring(i), function()
        local repos = getRepos()
        local repo = repos[i]
        if repo then
            hs.http.asyncGet("http://wormhole:7117/project/" .. repo, nil, function() end)
        end
    end)
end


local alertId = nil

local function getAvailableRepos()
    local available = {}
    local handle = io.popen("wormhole list")
    if handle then
        for line in handle:lines() do
            local repo = line:match("^%s*(.-)%s*$") -- trim whitespace
            if repo and repo ~= "" then
                available[repo] = true
            end
        end
        handle:close()
    end
    return available
end

local function showHotkeys()
    local workspace = getActiveWorkspace()
    local repos = getRepos()
    local availableRepos = getAvailableRepos()

    local lines = {}
    table.insert(lines, { text = string.format("Workspace: %s", workspace), available = true })
    table.insert(lines, { text = "", available = true })

    for i = 1, 9 do
        local repo = repos[i]
        if repo then
            local isAvailable = availableRepos[repo]
            local line = string.format("%d    %s", i, repo)
            table.insert(lines, { text = line, available = isAvailable })
        end
    end
    if repos[0] then
        local isAvailable = availableRepos[repos[0]]
        local line = string.format("0    %s", repos[0])
        table.insert(lines, { text = line, available = isAvailable })
    end

    if alertId then
        hs.alert.closeSpecific(alertId)
        alertId = nil
    else
        -- Create a custom styled text object
        local styledText = hs.styledtext.new("")

        for i, lineData in ipairs(lines) do
            local color = lineData.available and { white = 1, alpha = 1 } or { white = 0.5, alpha = 0.7 }
            local text = lineData.text .. (i < #lines and "\n" or "")
            local styledLine = hs.styledtext.new(text, {
                font = { size = 14 },
                color = color
            })
            styledText = styledText .. styledLine
        end

        alertId = hs.alert.show(styledText, {
            fillColor = { white = 0.1, alpha = 0.9 },
            strokeColor = { white = 0.3, alpha = 1 },
            strokeWidth = 2,
            radius = 10,
            fadeInDuration = 0.15,
            fadeOutDuration = 0.15,
            atScreenEdge = 0
        }, "♾️")
    end

    -- local tmuxCmd = string.format([[tmux display-message -d 5000 '%s']], hotkeyText:gsub("\n", "\\n"):gsub("'", "\\'"))
    -- hs.execute(tmuxCmd, true)
end

hs.hotkey.bind({}, "f16", terminal)
hs.hotkey.bind({}, "f13", wormholeSelect)
hs.hotkey.bind({ "cmd", "control" }, "left", wormholePrevious)
hs.hotkey.bind({ "cmd", "control" }, "right", wormholeNext)
hs.hotkey.bind({ "cmd", "control" }, ".", wormholePin)
hs.hotkey.bind({ "cmd", "alt" }, "k", showHotkeys)
hs.hotkey.bind({ "cmd", "alt" }, "r", function()
    hs.reload()
end)

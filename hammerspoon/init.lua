-- require("hs.inspect")
require("hs.ipc")
require("hs.eventtap")
require("hs.notify")

local hs = hs

Logger = hs.logger.new('dan', "debug")


-- https://www.hammerspoon.org/docs/hs.keycodes.html#map
-- https://github.com/alacritty/alacritty/issues/862#issuecomment-616873890

local function terminal()
    local name = "Alacritty"

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

local keymap = {
    ["server"] = {
        [1] = "temporal",
        [2] = "saas-temporal",
        [3] = "bench-go",
        [4] = "api",
        [5] = "api-go",
        [6] = "sdk-python",
        [7] = "obedience",
        [9] = "devenv",
        [0] = "temporal-all",
    },
    ["temporal-all"] = {
        [1] = "temporal-all",
        [2] = "sdk-python",
        [3] = "nexus-sdk-python",
        [4] = "sdk-core",
        [5] = "server",
        [6] = "sdk-go",
        [7] = "sdk-java",
        [8] = "sdk-typescript",
        [9] = "api",
        [0] = "devenv",
    },
    ["nexus"] = {
        [1] = "temporal-all",
        [2] = "sdk-python",
        [3] = "nexus-sdk-python",
        [4] = "sdk-typescript",
        [5] = "nexus-sdk-typescript",
        [6] = "sdk-go",
        [7] = "nexus-sdk-go",
        [8] = "sdk-java",
        [9] = "nexus-sdk-java",
        [0] = "devenv",
    },
    ["ai"] = {
        [1] = "temporal-all",
        [2] = "sdk-python",
        [3] = "mcp-python-sdk",
        [4] = "mcp-modelcontextprotocol",
        [5] = "a2a-python",
        [6] = "a2a-samples",
        [7] = "nexus-a2a-python",
        [8] = "nexus-mcp-python",
        [9] = "samples-python",
        [0] = "devenv",
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
    hs.hotkey.bind({"cmd"}, tostring(i), function()
        local repos = getRepos()
        local repo = repos[i]
        if repo then
            hs.http.get("http://wormhole:7117/project/" .. repo, nil)
        end
    end)
end

hs.hotkey.bind({}, "f16", terminal)
hs.hotkey.bind({}, "f13", wormholeSelect)
hs.hotkey.bind({ "cmd", "control" }, "left", wormholePrevious)
hs.hotkey.bind({ "cmd", "control" }, "right", wormholeNext)

local alertId = nil

local function getAvailableRepos()
    local available = {}
    local handle = io.popen("wormhole-list")
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
    table.insert(lines, {text = string.format("Workspace: %s", workspace), available = true})
    table.insert(lines, {text = "", available = true})

    for i = 1, 9 do
        local repo = repos[i]
        if repo then
            local isAvailable = availableRepos[repo]
            local line = string.format("%d    %s", i, repo)
            table.insert(lines, {text = line, available = isAvailable})
        end
    end
    if repos[0] then
        local isAvailable = availableRepos[repos[0]]
        local line = string.format("0    %s", repos[0])
        table.insert(lines, {text = line, available = isAvailable})
    end

    if alertId then
        hs.alert.closeSpecific(alertId)
        alertId = nil
    else
        -- Create a custom styled text object
        local styledText = hs.styledtext.new("")

        for i, lineData in ipairs(lines) do
            local color = lineData.available and {white = 1, alpha = 1} or {white = 0.5, alpha = 0.7}
            local text = lineData.text .. (i < #lines and "\n" or "")
            local styledLine = hs.styledtext.new(text, {
                font = {size = 14},
                color = color
            })
            styledText = styledText .. styledLine
        end

        alertId = hs.alert.show(styledText, {
            fillColor = {white = 0.1, alpha = 0.9},
            strokeColor = {white = 0.3, alpha = 1},
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

hs.hotkey.bind({"cmd", "alt"}, "k", showHotkeys)
hs.hotkey.bind({"cmd", "alt"}, "r", function()
    hs.reload()
end)

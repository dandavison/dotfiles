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
    ["act"] = {
        "temporal",                 -- 1
        "api",                      -- 2
        "sdk-python",               -- 3
        "samples-python",           -- 4
        "api-go",                   -- 5
        "devenv",                   -- 6
        "rgi"                       -- 7
    },
    ["temporal-all"] = {
        "temporal-all",                 -- 1
        "sdk-python",               -- 2
        "nexus-sdk-python",         -- 3
        "sdk-core",                 -- 4
        "server",                   -- 5
        "sdk-go"  ,                 -- 6
        "sdk-java",                 -- 7
        "sdk-typescript",           -- 8
        "api",                      -- 9
        "devenv",                   -- 0
    },
    ["nexus"] = {
        "temporal-all",                 -- 1
        "sdk-python",               -- 2
        "nexus-sdk-python",         -- 3
        "sdk-typescript",           -- 4
        "nexus-sdk-typescript",     -- 5
        "sdk-go"  ,                 -- 6
        "nexus-sdk-go",             -- 7
        "sdk-java",                 -- 8
        "nexus-sdk-java",           -- 9
        "devenv",                   -- 0
    },
    ["ai"] = {
        "temporal-all",                 -- 1
        "sdk-python",               -- 2
        "mcp-python-sdk",           -- 3
        "mcp-modelcontextprotocol", -- 4
        "a2a-python",               -- 5
        "a2a-samples",              -- 6
        "nexus-a2a-python",         -- 7
        "nexus-mcp-python",         -- 8
        "samples-python",           -- 9
        "devenv",                   -- 0
    }
}

local function getActiveWorkspace()
    local file = io.open("/tmp/ws", "r")
    if file then
        local content = file:read("*all")
        file:close()
        return content:match("^%s*(.-)%s*$")
    end
    return "act"
end

local function getRepos()
    local workspace = getActiveWorkspace()
    return keymap[workspace] or keymap["temporal"]
end

for i = 1, 10 do
    hs.hotkey.bind({"cmd"}, tostring(i % 10), function()
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

    for i, repo in ipairs(repos) do
        local isAvailable = availableRepos[repo]
        local line = string.format("%d    %s", i % 10, repo)
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

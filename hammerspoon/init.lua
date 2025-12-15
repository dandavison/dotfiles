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
        "temporal",
        "temporal-2",
        "bench-go",
        "api",
        "api-go",
        "obedience",
        "ro",
        "devenv",
    },
    ["temporal-all"] = {
        "temporal-all",
        "sdk-python",
        "nexus-sdk-python",
        "sdk-core",
        "server",
        "sdk-go"  ,
        "sdk-java",
        "sdk-typescript",
        "api",
        "devenv",
    },
    ["nexus"] = {
        "temporal-all",
        "sdk-python",
        "nexus-sdk-python",
        "sdk-typescript",
        "nexus-sdk-typescript",
        "sdk-go"  ,
        "nexus-sdk-go",
        "sdk-java",
        "nexus-sdk-java",
        "devenv",
    },
    ["ai"] = {
        "temporal-all",
        "sdk-python",
        "mcp-python-sdk",
        "mcp-modelcontextprotocol",
        "a2a-python",
        "a2a-samples",
        "nexus-a2a-python",
        "nexus-mcp-python",
        "samples-python",
        "devenv",
    }
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

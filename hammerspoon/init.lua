-- require("hs.inspect")
require("hs.ipc")
require("hs.eventtap")
require("hs.notify")


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

local projects = {
    "api",                   -- 1
    "sdk-python",            -- 2
    "nexus-sdk-python",      -- 3
    "samples-python",        -- 4
    "sdk-java",              -- 5
    "nexus-sdk-java",        -- 6
    "samples-java",          -- 7
    "sdk-go",                -- 8
    "nexus-sdk-go",          -- 9
    "devenv",  -- 0
}

for i, project in ipairs(projects) do
    hs.hotkey.bind({"cmd"}, tostring(i % 10), function()
        hs.http.get("http://wormhole:7117/project/" .. project, nil)
    end)
end

hs.hotkey.bind({}, "f16", terminal)
hs.hotkey.bind({}, "f13", wormholeSelect)
hs.hotkey.bind({ "cmd", "control" }, "left", wormholePrevious)
hs.hotkey.bind({ "cmd", "control" }, "right", wormholeNext)

local alertUUID = nil

local function showHotkeys()
    -- Build project shortcuts dynamically
    local lines = {}
    for i, project in ipairs(projects) do
        table.insert(lines, string.format("%d    %s", i % 10, project))
    end

    local text = table.concat(lines, "\n")

    if alertUUID then
        hs.alert.closeSpecific(alertUUID)
        alertUUID = nil
    else
        alertUUID = hs.alert.show(text, {
            textSize = 14,
            textColor = {white = 1, alpha = 1},
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

hs.hotkey.bind({"cmd", "shift"}, "k", showHotkeys)
hs.hotkey.bind({"cmd", "shift"}, "r", function()
    hs.reload()
end)


-- local current_id, threshold
-- Swipe = hs.loadSpoon("Swipe")
-- Swipe:start(3, function(direction, distance, id)
--     if id == current_id then
--         Logger.d("distance", distance)
--         if distance > threshold then
--             threshold = math.huge
--             if direction == "left" then
--                 wormholePrevious()
--             elseif direction == "right" then
--                 wormholeNext()
--             end
--         end
--     else
--         current_id = id
--         threshold = 0.05 -- swipe distance > % of trackpad
--     end
-- end)

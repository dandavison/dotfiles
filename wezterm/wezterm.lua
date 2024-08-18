local wezterm = require 'wezterm'

local config = wezterm.config_builder()


config.default_prog = { "/opt/homebrew/bin/zsh" }
config.font = wezterm.font { family = 'JetBrains Mono', weight = 'Bold' }
config.bold_brightens_ansi_colors = false
config.font_size = 13
config.color_scheme = 'Vs Code Light+ (Gogh)'
config.enable_tab_bar = false
config.default_cursor_style = 'SteadyBar'
config.audible_bell = 'Disabled'

config.keys = {
    {
        key = "x",
        mods = "ALT",
        action = wezterm.action.ActivateCommandPalette,
    },
    {
        key = "s",
        mods = "CMD",
        action = wezterm.action.ActivateCopyMode,
    },
    {
        key = "Return",
        mods = "CMD|SHIFT",
        action = wezterm.action.ToggleFullScreen,
    },
    -- pane navigation
    {
        key = "_",
        mods = "CMD",
        action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
        key = "+",
        mods = "CMD",
        action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
        key = "Return",
        mods = "CMD",
        action = wezterm.action.TogglePaneZoomState,
    },
    {
        key = "LeftArrow",
        mods = "CMD",
        action = wezterm.action.ActivatePaneDirection("Left"),
    },
    {
        key = "RightArrow",
        mods = "CMD",
        action = wezterm.action.ActivatePaneDirection("Right"),
    },
    {
        key = "DownArrow",
        mods = "CMD",
        action = wezterm.action.ActivatePaneDirection("Down"),
    },
    {
        key = "UpArrow",
        mods = "CMD",
        action = wezterm.action.ActivatePaneDirection("Up"),
    },
}
config.mouse_bindings = {
    -- https://wezfurlong.org/wezterm/config/mouse.html#configuring-mouse-assignments
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'NONE',
        action = wezterm.action.CompleteSelection 'ClipboardAndPrimarySelection',
    },
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'CMD',
        action = wezterm.action.OpenLinkAtMouseCursor,
    },
}

return config

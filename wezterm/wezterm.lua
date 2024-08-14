local wezterm = require 'wezterm'

return {
    default_prog = { "/opt/homebrew/bin/zsh" },
    font = wezterm.font { family = 'JetBrains Mono', weight = 'Bold' },
    bold_brightens_ansi_colors = false,
    font_size = 13,
    color_scheme = 'Vs Code Light+ (Gogh)',
    -- hide_tab_bar_if_only_one_tab = true,
    default_cursor_style = 'SteadyBar',
    audible_bell = 'Disabled',
    keys = {
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
    },
    mouse_bindings = {
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
        -- NOTE that binding only the 'Up' event can give unexpected behaviors.
        -- Read more below on the gotcha of binding an 'Up' event only.
    }
}

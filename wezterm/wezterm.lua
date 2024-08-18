local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_prog = { "/opt/homebrew/bin/zsh" }

local font_scheme = 'monaco-13-bold'

-- fonts and colors
if font_scheme == 'monaco-13-bold' then
    config.font = wezterm.font { family = 'Monaco', weight = 'Bold' }
    config.font_size = 13
    -- config.cell_width = 0.95
elseif font_scheme == 'monaco-14-regular' then
    config.font = wezterm.font { family = 'Monaco', weight = 'Regular' }
    config.font_size = 14
    -- config.cell_width = 0.95
elseif font_scheme == 'dejavusansm' then
    config.font = wezterm.font_with_fallback {
        'DejaVuSansM Nerd Font Mono', 'SF Mono'
    }
    config.font_size = 14
    config.cell_width = 0.90
end


-- https://github.com/wez/wezterm/issues/3774
-- config.front_end = 'OpenGL'
-- config.freetype_load_target = "Light"
-- config.freetype_render_target = "HorizontalLcd"
-- config.freetype_load_flags = 'NO_HINTING'
-- config.bold_brightens_ansi_colors = false
-- config.color_scheme = 'Vs Code Light+ (Gogh)'

--

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


-- colors

config.colors = {
    -- The default text color
    foreground = '#000000',
    -- The default background color
    background = '#fffefe',

    -- Cursor colors
    -- cursor_bg = 'CellForeground',
    -- cursor_fg = 'CellBackground',
    -- cursor_border = 'CellForeground',

    -- ANSI color palette
    ansi = {
        '#000000', -- black
        '#c91b00', -- red
        '#066c06', -- green
        '#e55611', -- yellow
        '#0225c7', -- blue
        '#c930c7', -- magenta
        '#0073c7', -- cyan
        '#c7c7c7', -- white
    },

    -- Bright ANSI color palette
    brights = {
        '#4c4c4c', -- black
        '#ff6d67', -- red
        '#5ff967', -- green
        '#fe9a67', -- yellow
        '#6871ff', -- blue
        '#ff76ff', -- magenta
        '#1e81b0', -- cyan
        '#6b6868', -- white
    },
}

return config

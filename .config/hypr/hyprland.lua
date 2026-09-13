-- Hyprland configuration (Lua).
--
-- Ported 1:1 from the previous hyprland.conf (hyprlang). Hyprland 0.56.2 logs
--   [cfg] Lua config not found, using legacy config at ~/.config/hypr/hyprland.conf
-- and prefers hyprland.lua when present, so this file now wins and the old
-- hyprland.conf is kept only as a reference/rollback.
--
-- API reference: /run/current-system/sw/share/hypr/stubs/hl.meta.lua
-- (point your Lua LSP at it for completion), example config:
-- /run/current-system/sw/share/hypr/hyprland.lua
--
-- Validate without starting a session:  Hyprland --verify-config -c <this file>

------------------
---- MONITORS ----
------------------

-- was: monitor=DP-3,3440x1440@175,0x0,1
hl.monitor({
    output   = "DP-3",
    mode     = "3440x1440@175",
    position = "0x0",
    scale    = 1,
})


---------------------
---- MY PROGRAMS ----
---------------------

-- were: $terminal / $fileManager / $menu
local terminal    = "ghostty"
local fileManager = "nautilus"
local menu        = "noctalia msg panel-toggle launcher"


-------------------
---- AUTOSTART ----
-------------------

-- were: exec-once = ...
-- hyprpaper stays disabled: noctalia v5 manages the wallpaper itself and the
-- two conflict. Wallpaper is set in ~/.nixos/modules/noctalia.nix.
hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia")
    hl.exec_cmd("streamcontroller -b")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- were: env = KEY,VALUE
-- NOTE: these only reach processes Hyprland spawns. Systemd/D-Bus-activated
-- services (portals etc.) read ~/.config/uwsm/env instead, which home-manager
-- generates from home.nix -- keep the two in sync.
-- The old conf set XCURSOR_SIZE twice; the duplicate is dropped here.
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GDK_SCALE", "1")
hl.env("GDK_DPI_SCALE", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },

    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        -- Alabaster Dark colors
        col = {
            -- blue -> purple gradient
            active_border   = { colors = { "rgba(61afefee)", "rgba(c678ddee)" }, angle = 45 },
            -- subtle gray border
            inactive_border = "rgba(2c2f34ff)",
        },

        resize_on_border = true,

        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 8,
        rounding_power = 2,

        active_opacity   = 0.97,
        inactive_opacity = 0.92,

        shadow = {
            enabled      = true,
            range        = 6,
            render_power = 3,
            -- Alabaster Dark background shadow
            color        = "rgba(0b0c0dcc)",
        },

        blur = {
            enabled  = true,
            size     = 6,
            passes   = 2,
            vibrancy = 0.18,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    scrolling = {
        column_width = 0.49,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        vrr                     = 0,
    },
})


--------------------
---- ANIMATIONS ----
--------------------

-- were: bezier = NAME, X0, Y0, X1, Y1
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

-- were: animation = NAME, ONOFF, SPEED, CURVE, [STYLE]
hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "slide" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "slide" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us,ru",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- was: gesture = 3, horizontal, workspace
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- was: device { name = ...; accel_profile = flat; sensitivity = 0 }
hl.device({
    name          = "lamzu-lamzu-maya-x-8k-dongle-1",
    accel_profile = "flat",
    sensitivity   = 0,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "ALT"

hl.bind("CTRL + SPACE", hl.dsp.exec_cmd(menu))

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + q",      hl.dsp.window.close())
hl.bind(mainMod .. " + M",      hl.dsp.exit())
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }))

-- Layout switching. Kept as `hyprctl keyword` (as in the old conf) rather than
-- hl.config(), because `keyword` is explicitly a runtime override and this
-- avoids changing semantics during the port.
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("hyprctl keyword general:layout dwindle"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("hyprctl keyword general:layout scrolling"))

-- Groups. The old conf shelled out to `hyprctl dispatch togglegroup` /
-- `changegroupactive f|b`; these are the native equivalents, no subprocess.
hl.bind(mainMod .. " + t", hl.dsp.group.toggle())
hl.bind(mainMod .. " + N", hl.dsp.group.next())

-- !! PRE-EXISTING CONFLICT, PORTED AS-IS !!
-- The old conf bound ALT+P twice: once to `pseudo` (line 154) and again to
-- `changegroupactive b` (line 159). Only one of them can ever win. Both are
-- kept here so behaviour is unchanged; decide which you actually want and
-- delete the other.
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + P", hl.dsp.group.prev())

-- Focus (vim keys)
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-10 (10 maps to key 0), and move-window-to-workspace
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Swap windows
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- were: bindm (mouse binds)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- were: bindel (locked + repeating)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- were: bindl (locked)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Keyboard layout switching
hl.bind("CTRL + ALT + BACKSLASH",         hl.dsp.exec_cmd("hyprctl keyword input:kb_layout us"))
hl.bind("CTRL + ALT + SHIFT + BACKSLASH", hl.dsp.exec_cmd("hyprctl keyword input:kb_layout ru"))


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- was: windowrule = suppress_event maximize, match:class .*
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- was: windowrule = no_focus on, match:class ^$, match:title ^$, match:xwayland true
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class    = "^$",
        title    = "^$",
        xwayland = true,
    },

    no_focus = true,
})

local wezterm = require 'wezterm';

return {
	term = "xterm-256color",
	enable_tab_bar = false,
	font = wezterm.font("FiraCode Nerd Font", {italic = false}),
	color_scheme = "Gruvbox",
	color_schemes = {
		["Gruvbox"] = {
			foreground = "#ebdbb2",
			background = "#282828",
			cursor_bg = "#ebdbb2",
			cursor_border = "#ebdbb2",
			cursor_fg = "#282828",
			selection_bg = "#655b53",
			selection_fg = "#ebdbb2",

			ansi = {"#282828", "#cc231c", "#989719", "#d79920", "#448488", "#b16185", "#689d69", "#a89983"},
			brights = {"#928373", "#fb4833", "#b8ba25", "#fabc2e", "#83a597", "#d3859a", "#8ec07b", "#ebdbb2"},
		}
	},
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0
	}
}

local wezterm = require 'wezterm'
local config = {}

config.colors = {
	cursor_bg = 'white',
	cursor_border = 'white' -- Needed for inactive cursor, when clicked out of window
}

-- Disables ligatures
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

return config


-- Utils
local Map = require('utils').Map

-- Leader key (must be set before plugins load)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Plugins (setup now lives in lua/plugins.lua via lazy specs)
require('plugins')

-- Main config (theme, keybindings etc.)
require('main-config')

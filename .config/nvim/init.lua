-- Utils
local Map = require('utils').Map

-- Plugins
require('plugins')

-- Main config (theme, keybingings etc.)
require('main-config')

-- LSP
require('lsp-config')

-- Autoclose / autopairs
require('nvim-autopairs').setup()

-- NeoScroll
require('neoscroll').setup()

-- Nvim tree
require('nvimtree-config')

-- LuaLine
require('lualine-config')

-- Trouble
require('trouble').setup()

-- Hop (EasyMotion)
require('hop').setup { keys = 'etovxqpdygfblzhckisuran' }
vim.api.nvim_set_keymap('', 's', "<cmd>lua require'hop'.hint_char1({})<cr>", {})

-- Scrollbar
require('scrollbar-config')

-- Git signs
require('gitsigns').setup()
require('scrollbar.handlers.gitsigns').setup()

-- IndentLine
require('indentline-config')

-- Telescope
require('telescope-config')

-- NeoFormat
require('neoformat-config')

-- TreeSitter
require('treesitter')

-- Argwrap
Map('n', '<leader>a', ':ArgWrap<CR>')
vim.g['argwrap_padded_braces'] = '{'

-- Spectre (find/replace)
require('spectre-config')

-- TagBar
Map('n', '<leader>t', ':TagbarToggle<CR>')

-- Trouble
Map('n', 'tt', '<cmd>TroubleToggle<cr>')

local set = vim.opt
local Map = require('utils').Map

-- Splits
set.splitright = true
set.splitbelow = true

-- Clipboard
set.clipboard = "unnamedplus"
Map('n', 'yy', ':let @* = expand("%")<CR>')

-- Fish as default shell
-- set.shell = '/usr/local/bin/fish'

-- Colorscheme
vim.cmd [[
  colorscheme gruvbox
]]
set.termguicolors = true
set.background = 'dark'

-- Relative line numbers
set.rnu = true

-- Rulers
set.colorcolumn = {'80', '100'}

-- Show special chars
set.list = true
vim.cmd [[
  set listchars=tab:→\ ,trail:·,extends:⋯,precedes:⋯,nbsp:~
]]

-- Sign column
set.signcolumn = 'yes'

-- Nowrap
set.wrap = false

-- Nofold
set.foldenable = false

-- Yank
Map('n', 'Y', 'Y')

-- Statusline
set.laststatus = 3

-- Tab navigation
Map('n', '<S-h>', ':BufferLineCyclePrev<CR>')
Map('n', '<S-l>', ':BufferLineCycleNext<CR>')
Map('n', '<S-j>', ':BufferLineMovePrev<CR>')
Map('n', '<S-k>', ':BufferLineMoveNext<CR>')
Map('n', 'gb', ':BufferLinePick<CR>')

-- Split navigation
Map('n', '<leader>w', '<C-w>w')
Map('n', '<C-j>', '<C-W><C-J>')
Map('n', '<C-k>', '<C-W><C-K>')
Map('n', '<C-l>', '<C-W><C-L>')
Map('n', '<C-h>', '<C-W><C-H>')

-- Split resizing
Map('n', '>', ':vertical resize +10<CR>')
Map('n', '<', ':vertical resize -10<CR>')

-- Buffer close
Map('n', '<leader>q', ':bp<bar>sp<bar>bn<bar>bd<CR>')

-- Tmux background
vim.cmd [[
  autocmd VimEnter * highlight Normal ctermfg=223 ctermbg=none guifg=#ebdbb2 guibg=#282828 guibg=none
  autocmd VimEnter * highlight VertSplit ctermfg=241 ctermbg=none guifg=#665c54 guibg=#282828 guibg=none
]]

-- Search
Map('n', '<CR>', ':noh<CR>')

-- Symbols outline
Map('n', 'mm', ':SymbolsOutline<CR>')

-- Quickfix
vim.cmd [[
  autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
]]

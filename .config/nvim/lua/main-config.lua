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
-- require("gruvbox").setup({
--   italic = {
--     strings = false,
--     emphasis = false,
--     opearators = false,
--     folds = false,
--   }
-- })
-- vim.o.background = "dark" -- or "light" for light mode
-- vim.cmd([[colorscheme gruvbox]])
vim.o.background = "light" -- or "light" for light mode
vim.cmd([[colorscheme alabaster]])

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
Map('n', '<C-j>', ':TmuxNavigateDown<CR>')
Map('n', '<C-k>', ':TmuxNavigateUp<CR>')
Map('n', '<C-l>', ':TmuxNavigateRight<CR>')
Map('n', '<C-h>', ':TmuxNavigateLeft<CR>')

-- Split resizing
Map('n', '>', ':vertical resize +10<CR>')
Map('n', '<', ':vertical resize -10<CR>')

-- Buffer close
Map('n', '<leader>q', ':bp<bar>sp<bar>bn<bar>bd<CR>')

-- Tmux background
-- vim.cmd [[
--   autocmd VimEnter * highlight Normal ctermfg=223 ctermbg=none guifg=#ebdbb2 guibg=#282828 guibg=none
--   autocmd VimEnter * highlight VertSplit ctermfg=241 ctermbg=none guifg=#665c54 guibg=#282828 guibg=none
-- ]]
if vim.fn.exists('$TMUX') == 1 then
  vim.cmd [[
    " Detect entering or leaving a tmux pane
    autocmd FocusGained * hi Normal guibg=#F7F7F7 guifg=#2E2E2E
    autocmd FocusLost   * hi Normal guibg=#EDEDED guifg=#7B7B7B

    autocmd FocusGained * hi VertSplit guibg=#F7F7F7 guifg=#D0D0D0
    autocmd FocusLost   * hi VertSplit guibg=#EDEDED guifg=#C0C0C0
  ]]
end

-- Search
Map('n', '<CR>', ':noh<CR>')

-- Symbols outline
Map('n', 'mm', ':SymbolsOutline<CR>')

-- Quickfix
vim.cmd [[
  autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
]]

-- Clear SpellCap
vim.cmd [[
  hi clear SpellCap
]]

-- Backup dir
set.backupdir = '/tmp'

-- Copilot
vim.g.copilot_no_tab_map = true
Map('i', '<C-F>', 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false })

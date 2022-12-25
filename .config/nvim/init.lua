local set = vim.opt

function Map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- Plugins
require("plugins")

-- LSP
require("lsp-config")

-- Autoclose / autopairs
require('nvim-autopairs').setup()

-- Nvim tree
require("icons")
require("nvim-tree").setup()
require("bufferline").setup {
  highlights ={
    fill = { bg = 'none' },
    background = { bg = 'none' },
    tab = { bg = 'none' },
    tab_selected = { bg = 'none' },
    buffer_selected = { bg = 'none', bold = true, italic = false },
    numbers_selected = { bg = 'none', bold = true, italic = false },
    numbers = { bg = 'none' },
    numbers_visible = { bg = 'none' },
    buffer_visible = { bg = 'none' },
    separator = { bg = 'none' },
    separator_visible = { bg = 'none' },
    indicator_selected = { fg = 'orange', bg = 'none' },
  },
  options = {
    numbers = function(opts)
      return string.format('%s', opts.id)
    end,
    left_trunc_marker = "",
    right_trunc_marker = "",
    offsets = {{filetype = "NvimTree", text = "File Explorer", text_align = "left"}},
    show_tab_indicators = true,
    show_close_icon = false,
    show_buffer_close_icons = false,
    separator_style = { '', '' }
  }
}

-- NeoScroll
require('neoscroll').setup()

-- LuaLine
require('lualine').setup {
  options = {
    theme = 'gruvbox'
  },
  sections = {
    lualine_a = {'mode'},
    lualine_c = {{'filename', path=1}},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'lsp_progress'},
    lualine_z = {'location'}
  },
  extensions = {'quickfix', 'nvim-tree'}
}

-- Trouble
require('trouble').setup {}

-- Hop (EasyMotion)
require('hop').setup { keys = 'etovxqpdygfblzhckisuran' }
vim.api.nvim_set_keymap('', 's', "<cmd>lua require'hop'.hint_char1({})<cr>", {})

-- Scrollbar
require('scrollbar').setup({
  marks = {
    GitAdd = { color = 'LightGreen' },
    GitChange = { color = 'LightBlue' },
    GitDelete = { color = 'Orange' }
  },
  handlers = {
    gitsigns = true
  }
})

-- Git signs
require('gitsigns').setup()
require('scrollbar.handlers.gitsigns').setup()

-- Splits
set.splitright = true
set.splitbelow = true

-- Clipboard
set.clipboard = "unnamedplus"
Map('n', 'yy', ':let @* = expand("%")<CR>')

-- Fish as default shell
set.shell = '/usr/local/bin/fish'

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

-- IndentLine
vim.g['indentLine_char_list'] = {'┊'}
vim.g['indentLine_fileTypeExclude'] = {'dashboard'}
vim.g['vim_markdown_conceal'] = 0
vim.g['vim_markdown_conceal_code_blocks'] = 0

-- FileFinder
Map('n', '<C-p>', '<cmd>Telescope find_files<cr>')
Map('n', '<C-g>', '<cmd>Telescope live_grep<cr>')
Map('n', '<C-b>', '<cmd>Telescope buffers<cr>')

-- Prettier
vim.g['prettier#exec_cmd_async'] = 1
vim.g['prettier#autoformat_require_pragma'] = 0
vim.g['prettier#autoformat_config_present'] = 1

-- FileExplorer
Map('n', '<C-n>', ':NvimTreeToggle<CR>')
Map('n', '<C-f>', ':NvimTreeFindFile<CR>')
vim.cmd [[
  highlight NvimTreeFolderIcon guifg=orange
  highlight NvimTreeFolderName guifg=fg0
  highlight NvimTreeGitDirty guifg=red
  highlight NvimTreeOpenedFolderName guifg=fg0
  highlight NvimTreeEmptyFolderName guifg=fg0
  highlight NvimTreeIndentMarker guifg=orange
]]

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

-- Argwrap
Map('n', '<leader>a', ':ArgWrap<CR>')
vim.g['argwrap_padded_braces'] = '{'

-- Tmux background
vim.cmd [[
  autocmd VimEnter * highlight Normal ctermfg=223 ctermbg=none guifg=#ebdbb2 guibg=#282828 guibg=none
  autocmd VimEnter * highlight VertSplit ctermfg=241 ctermbg=none guifg=#665c54 guibg=#282828 guibg=none
]]

-- Search
Map('n', '<CR>', ':noh<CR>')

-- Find/replace
Map('n', '<leader>S', ':lua require("spectre").open()<CR>')
Map('n', '<leader>sw', ':lua require("spectre").open_visual({select_word=true})<CR>')
Map('n', '<leader>s', 'viw:lua require("spectre").open_file_search()<cr>')

-- TagBar
Map('n', '<leader>t', ':TagbarToggle<CR>')

-- NeoFormat
vim.g[':neoformat_try_node_exe'] = 1
vim.cmd [[
  autocmd BufWritePre *.js Neoformat
  autocmd BufWritePre *.jsx Neoformat
  autocmd BufWritePre *.ts Neoformat
  autocmd BufWritePre *.tsx Neoformat
]]

-- Trouble
Map('n', 'tt', '<cmd>TroubleToggle<cr>')

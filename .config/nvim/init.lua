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

-- Snippets
local cmp = require('cmp')
local lspkind = require('lspkind')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = {
    ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
    ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true})
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer' },
  }, {
    { name = 'buffer' },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      maxwidth = 50,
    })
  }
})

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = true,
  severity_sort = true,
})

vim.o.updatetime = 250
vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
require('lspconfig').eslint.setup {
  capabilities = capabilities
}

require('lspconfig').tsserver.setup {
  capabilities = capabilities
}

require('lspconfig').solargraph.setup {
  capabilities = capabilities
}

-- Snippets
require('luasnip/loaders/from_vscode').lazy_load()

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

-- Redo
Map('n', '<C-u>', ':redo<CR>')

-- IndentLine
vim.g['indentLine_char_list'] = {'┊'}
vim.g['indentLine_fileTypeExclude'] = {'dashboard'}
vim.g['vim_markdown_conceal'] = 0
vim.g['vim_markdown_conceal_code_blocks'] = 0

-- FileFinder
Map('n', '<C-p>', '<cmd>Telescope find_files<cr>')
Map('n', '<C-r>', '<cmd>Telescope live_grep<cr>')
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

-- LSP
Map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
Map('n', 'M', '<cmd>lua vim.lsp.buf.hover()<CR>')

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

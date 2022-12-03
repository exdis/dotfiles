call plug#begin('~/.local/share/nvim/plugged')

" Theme
Plug 'morhetz/gruvbox'

" Lualine
Plug 'hoob3rt/lualine.nvim'

" Language support
Plug 'sheerun/vim-polyglot'

" FuzzyFinder
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" FileExplorer
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'

" TabLine
Plug 'akinsho/nvim-bufferline.lua'

" Surround Vim
Plug 'tpope/vim-surround'

" Commentary
Plug 'tpope/vim-commentary'

" Hop (Easymotion)
Plug 'phaazon/hop.nvim'

" Argwrap
Plug 'FooSoft/vim-argwrap'

" Autoclose
Plug 'Raimondi/delimitMate'

" IndentLine
Plug 'Yggdroot/indentLine'

" Find/replace
Plug 'nvim-lua/plenary.nvim'
Plug 'windwp/nvim-spectre'

" Smooth scroll
Plug 'karb94/neoscroll.nvim'

" Editorconfig
Plug 'editorconfig/editorconfig-vim'

" TagBar
Plug 'preservim/tagbar'

" LSP
Plug 'neovim/nvim-lspconfig'

" Autocomplete
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/nvim-cmp'

" Snippets
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'

" Suggest icons
Plug 'onsails/lspkind.nvim'

" Trouble
Plug 'folke/trouble.nvim'

" Prettier
Plug 'sbdchd/neoformat'

" LSP progress
Plug 'arkav/lualine-lsp-progress'

" Scrollbar
Plug 'petertriho/nvim-scrollbar'

" Git signs
Plug 'lewis6991/gitsigns.nvim'

call plug#end()

set signcolumn=yes

lua << EOF
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
require('neoscroll').setup()
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

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
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
EOF

" Splits
set splitright
set splitbelow

" Clipboard
set clipboard=unnamedplus
nnoremap <silent> yy :let @* = expand("%")<CR>

" Fish as default shell
set shell=/usr/local/bin/fish

let $NVIM_TUI_ENABLE_TRUE_COLOR=1

colorscheme gruvbox

set termguicolors

" Relative line numbers
set rnu

" Rulers
set colorcolumn=80,100

" Show special chars
set list
set listchars=tab:→\ ,trail:·,extends:⋯,precedes:⋯,nbsp:~

" Nowrap
set nowrap

" Nofold
set nofoldenable

" Yank
nnoremap Y Y

" Statusline
set laststatus=3

" IndentLine
let g:indentLine_char_list = ['┊']
let g:indentLine_fileTypeExclude = ['dashboard']
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0

" FileFinder
nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <C-r> <cmd>Telescope live_grep<cr>
nnoremap <C-b> <cmd>Telescope buffers<cr>

" Prettier
let g:prettier#exec_cmd_async = 1
let g:prettier#autoformat_require_pragma = 0
let g:prettier#autoformat_config_present = 1

" FileExplorer
nnoremap <silent> <C-n> :NvimTreeToggle<CR>
nnoremap <silent> <C-f> :NvimTreeFindFile<CR>
highlight NvimTreeFolderIcon guifg=orange
highlight NvimTreeFolderName guifg=fg0
highlight NvimTreeGitDirty guifg=red
highlight NvimTreeOpenedFolderName guifg=fg0
highlight NvimTreeEmptyFolderName guifg=fg0
highlight NvimTreeIndentMarker guifg=orange

" Tab navigation
nmap <silent> <S-h> :BufferLineCyclePrev<CR>
nmap <silent> <S-l> :BufferLineCycleNext<CR>
nmap <silent> <S-j> :BufferLineMovePrev<CR>
nmap <silent> <S-k> :BufferLineMoveNext<CR>
nnoremap <silent> gb :BufferLinePick<CR>

" Split navigation
nmap <leader>w <C-w>w
nnoremap <C-j> <C-W><C-J>
nnoremap <C-k> <C-W><C-K>
nnoremap <C-l> <C-W><C-L>
nnoremap <C-h> <C-W><C-H>

" Loclist
function LCEmpty()
  return empty(getloclist('.'))
endfunction

function LCOpen()
  if LCEmpty() | call setloclist(0, []) | endif
  return filter(getwininfo(), 'v:val.loclist') == []
endfunction

function ToggleLC()
  if LCOpen() | lopen | else | lclose | endif
endfunction

nnoremap <silent> <C-m> :call ToggleLC()<CR>

" Argwrap
nnoremap <silent> <leader>a :ArgWrap<CR>
let g:argwrap_padded_braces = '{'

" Tmux background
autocmd VimEnter * highlight Normal ctermfg=223 ctermbg=none guifg=#ebdbb2 guibg=#282828 guibg=none
autocmd VimEnter * highlight VertSplit ctermfg=241 ctermbg=none guifg=#665c54 guibg=#282828 guibg=none

" Search
nnoremap <silent> <CR> :noh<CR>

" Find/replace
nnoremap <leader>S :lua require('spectre').open()<CR>
nnoremap <leader>sw :lua require('spectre').open_visual({select_word=true})<CR>
nnoremap <leader>s viw:lua require('spectre').open_file_search()<cr>

" TagBar
nmap <silent> <leader>t :TagbarToggle<CR>

" LSP
nnoremap <silent>gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent>M <cmd>lua vim.lsp.buf.hover()<CR>

" NeoFormat
let g:neoformat_try_node_exe = 1
autocmd BufWritePre *.js Neoformat
autocmd BufWritePre *.jsx Neoformat
autocmd BufWritePre *.ts Neoformat
autocmd BufWritePre *.tsx Neoformat

" Trouble
nnoremap tt <cmd>TroubleToggle<cr>

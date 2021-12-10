call plug#begin('~/.local/share/nvim/plugged')

" Dashboard
Plug 'glepnir/dashboard-nvim'

" Theme
Plug 'morhetz/gruvbox'

" Lualine
Plug 'hoob3rt/lualine.nvim'

" Language support
Plug 'sheerun/vim-polyglot'

" Linting/Language servers
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" FuzzyFinder
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Prettier
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'html']
  \ }

" FileExplorer
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'

" TabLine
Plug 'akinsho/nvim-bufferline.lua'

" Surround Vim
Plug 'tpope/vim-surround'

" Commentary
Plug 'tpope/vim-commentary'

" Easymotion
Plug 'easymotion/vim-easymotion'

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

call plug#end()

lua << EOF
require("icons")
require("nvimtree")
require("bufferline").setup {
  highlights ={
    fill = { guibg = 'none' },
    background = { guibg = 'none' },
    tab = { guibg = 'none' },
    tab_selected = { guibg = 'none' },
    buffer_selected = { guibg = 'none', gui = 'bold' },
    buffer_visible = { guibg = 'none' },
    separator = { guibg = 'none' },
    separator_visible = { guibg = 'none' },
    indicator_selected = { guifg = 'orange', guibg = 'none' },
  },
  options = {
    numbers = "buffer_id",
    number_style = "",
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
    lualine_b = {{'g:coc_status', left_padding = 0}, {'diagnostics', sources = {'coc'}}},
    lualine_c = {{'filename', path=1}},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  extensions = {'quickfix', 'nvim-tree'}
}
EOF

" Dashboard
let g:dashboard_default_executive = 'telescope'
let g:dashboard_custom_header = [
\ ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
\ ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
\ ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
\ ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
\ ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
\ ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
\]

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

" IndentLine
let g:indentLine_char_list = ['┊']
let g:indentLine_fileTypeExclude = ['dashboard']

" FileFinder
nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <C-r> <cmd>Telescope live_grep<cr>
nnoremap <C-b> <cmd>Telescope buffers<cr>

" Autocomplete
" inoremap <expr> <TAB> pumvisible() ? "<C-y>" : "<TAB>"
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ?
      \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

    function! s:check_back_space() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    let g:coc_snippet_next = '<tab>'

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
nmap <silent> <C-t> :tabnew<CR>
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

" Easymotion
nmap s <Plug>(easymotion-overwin-f)

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

" CoC
" Set internal encoding of vim, not needed on neovim, since coc.nvim using some
" unicode characters in the file autoload/float.vim
set encoding=utf-8

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=1

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> M :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
" xmap <leader>a  <Plug>(coc-codeaction-selected)
" nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
" nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
" nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-q> and <C-w> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-q> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-q>"
  nnoremap <silent><nowait><expr> <C-e> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-e>"
  inoremap <silent><nowait><expr> <C-q> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-e> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-q> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-q>"
  vnoremap <silent><nowait><expr> <C-e> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-e>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" CoCSnippets
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

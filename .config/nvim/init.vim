call plug#begin('~/.local/share/nvim/plugged')

" Theme
Plug 'morhetz/gruvbox'

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Language support
Plug 'sheerun/vim-polyglot'

" Linting
Plug 'dense-analysis/ale'

" FuzzyFinder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Prettier
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install',
  \ 'for': ['javascript', 'typescript', 'typescriptreact', 'javascriptreact']
  \ }

" NERDTree
Plug 'preservim/nerdtree' |
  \ Plug 'Xuyuanp/nerdtree-git-plugin'

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

call plug#end()

" Clipboard
set clipboard=unnamedplus

" Airline
let g:airline_powerline_fonts = 1

" Fish as default shell
set shell=/usr/local/bin/fish

let $NVIM_TUI_ENABLE_TRUE_COLOR=1

autocmd vimenter * ++nested colorscheme gruvbox

" Relative line numbers
set rnu

" Rulers
set colorcolumn=80,100

" Nowrap
set nowrap

" Fzf settings
nnoremap <C-p> :GFiles<CR>
nnoremap <C-r> :Rg<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>h :History<CR>
let g:fzf_action = {
  \ 'return': 'tab split', 
  \ 'ctrl-h': 'split',
  \ 'ctrl-v': 'vsplit' }

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

" Ale
let g:ale_sign_error = '❌'
let g:ale_sign_warning = '⚠️'

" Prettier
let g:prettier#exec_cmd_async = 1
let g:prettier#autoformat_require_pragma = 0
let g:prettier#autoformat_config_present = 1

" NERDTree
set splitright
set splitbelow
nnoremap <silent> <C-n> :NERDTreeToggle<CR>
nnoremap <silent> <C-f> :NERDTreeFind<CR>
let g:NERDTreeMapOpenVSplit = '<C-v>'
let g:NERDTreeMapOpenSplit = '<C-h>'
set guifont=DroidSansMono_Nerd_Font:h11

" Tab navigation
nmap <silent> <S-h> :tabprevious<CR>
nmap <silent> <S-l> :tabnext<CR>
nmap <silent> <S-j> :tabmove -1<CR>
nmap <silent> <S-k> :tabmove +1<CR>
nmap <silent> <C-t> :tabnew<CR>

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


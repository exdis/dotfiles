call plug#begin('~/.local/share/nvim/plugged')

" Theme
Plug 'morhetz/gruvbox'

" Airline
Plug 'vim-airline/vim-airline'

" Language support
Plug 'sheerun/vim-polyglot'

" Linting
Plug 'dense-analysis/ale'

" FuzzyFinder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Autocomplete
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

" Fish as default shell
set shell=/usr/local/bin/fish

let $NVIM_TUI_ENABLE_TRUE_COLOR=1

autocmd vimenter * ++nested colorscheme gruvbox

let g:ale_sign_error = '❌'
let g:ale_sign_warning = '⚠️'

" Relative line numbers
set rnu

" Fzf settings
nnoremap <C-p> :Files<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>h :History<CR>

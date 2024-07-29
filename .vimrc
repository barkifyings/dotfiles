let mapleader =","
map <Tab> :NERDTreeToggle<CR>
map <leader> :Goyo<CR>

call plug#begin('~/.vim/autoload')
Plug 'preservim/nerdtree'
Plug 'junegunn/goyo.vim'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'itchyny/lightline.vim'
Plug 'ap/vim-css-color'
call plug#end()

set laststatus=2
set hidden
set encoding=utf-8
set fileencoding=utf-8
set t_Co=256
set ruler
set number
set smartindent
set clipboard=unnamedplus
set formatoptions-=cro
set autoindent
syntax on
set nobackup
set nowritebackup
set noswapfile
set t_u7=
set bg=dark
let g:gruvbox_contrast_dark='hard'
silent colorscheme gruvbox


syntax on
" Show line number
set number
" Set relative number by default
set relativenumber
nnoremap B ^
nnoremap E $
filetype plugin indent on
" On pressing tab, insert 2 spaces
set expandtab
" show existing tab with 2 spaces width
set tabstop=2
set softtabstop=2
" when indenting with '>', use 2 spaces width
set shiftwidth=2
" Shift to the next round tab stop. 
set shiftround  
" Set auto indent spacing.
set shiftwidth=2
set mouse=a
map <C-n> :NERDTreeToggle<CR>
map <S-f> :Files<CR>
nnoremap <Left>  :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up>    :echoe "Use k"<CR>
nnoremap <Down>  :echoe "Use j"<CR>
" Enable Highlight Search
set hlsearch
" Highlight while search
set incsearch
" Case Insensitivity Pattern Matching
set ignorecase
" Overrides ignorecase if pattern contains upcase
set smartcase
" Keep search results at the center of screen
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz
" Press <leader> Enter to remove search highlights
noremap <silent> <leader><cr> :noh<cr>
:nnoremap <Leader>b :buffers<CR>:buffer<Space>
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
" Switch between tabs
nnoremap <Leader>1 1gt
nnoremap <Leader>2 2gt
nnoremap <Leader>3 3gt
nnoremap <Leader>4 4gt
nnoremap <Leader>5 5gt
nnoremap <Leader>6 6gt
nnoremap <Leader>7 7gt
nnoremap <Leader>8 8gt
nnoremap <Leader>9 9gt
" Easily create a new tab.
noremap <Leader>tN :tabnew<CR>
" Easily close a tab.
noremap <Leader>tc :tabclose<CR>
" Easily move a tab.
noremap <Leader>tm :tabmove<CR>
" Easily go to next tab.
noremap <Leader>tn :tabnext<CR>
" Easily go to previous tab.
noremap <Leader>tp :tabprevious<CR>
" Quickly source .vimrc
nnoremap <leader>r :source $MYVIMRC<CR>
nmap <Leader>gs :Gstatus<cr>
nmap <Leader>gc :Gcommit -v<cr>
nmap <Leader>ga :Git add -p<cr>
nmap <Leader>gp :Gpush<cr>
nmap <Leader>gd :Gdiff<cr>
nmap <Leader>gw :Gwrite<cr>
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-fugitive'
Plug 'christoomey/vim-conflicted'
Plug 'tpope/vim-rhubarb'
Plug 'neovimhaskell/haskell-vim'
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
Plug 'lpenz/vim-codefmt-haskell'
call plug#end()

" Remapped CAPSLOCK to <Esc>
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-surround'
Plug 'unblevable/quick-scope'
call plug#end()
"Autoreload a buffer when a file changes
set autoread
syntax on
" Show line number
set number
" Set relative number by default
set relativenumber
set encoding=UTF-8
set wrap
set linebreak
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
" Tmux inspired defaults for panes/windows.
nnoremap <leader><bar> <C-w>v
nnoremap <leader>- <C-w>s
" Better mapping for kill-pane
nnoremap <C-w>x <C-w>c
map <C-n> :NERDTreeToggle<CR>
vmap gcc <plug>NERDCommenterToggle
nmap gcc <plug>NERDCommenterToggle
" Close NERDTree if it is the only pane open.
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
map <leader>f :Files<CR>
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
noremap <Leader>tn :tabnew<CR>
" Easily close a tab.
noremap <Leader>tc :tabclose<CR>
" Easily move a tab.
noremap <Leader>tm :tabmove<CR>
" Easily go to next tab.
noremap <Leader>tN :tabnext<CR>
" Easily go to previous tab.
noremap <Leader>tP :tabprevious<CR>
" Quickly source .vimrc


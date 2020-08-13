" Remapped CAPSLOCK to <Esc>
syntax on
" Show line number
set number
" Set relative number by default
set relativenumber
set encoding=UTF-8
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
" Tmux inspired defaults for panes.
nnoremap <leader><bar> <C-w>v
nnoremap <leader>- <C-w>s
" Better mapping for kill-pane
nnoremap <C-w>x <C-w>c
map <C-n> :NERDTreeToggle<CR>
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
nnoremap <leader>r :source $MYVIMRC<CR>
nmap <Leader>gs :Gstatus<cr>
nmap <Leader>gb :Git branch<cr>
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
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-fugitive'
Plug 'christoomey/vim-conflicted'
Plug 'tpope/vim-rhubarb'
Plug 'neovimhaskell/haskell-vim'
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
Plug 'lpenz/vim-codefmt-haskell'
Plug 'romainl/vim-cool' 
Plug 'mhinz/vim-startify'
Plug 'roxma/vim-tmux-clipboard'
Plug 'patstockwell/vim-monokai-tasty'
Plug 'dart-lang/dart-vim-plugin'
Plug 'thosakwe/vim-flutter'
call plug#end()
colorscheme vim-monokai-tasty
let g:lightline = {
      \ 'colorscheme': 'monokai_tasty',
      \ }
" coc config
let g:coc_global_extensions = [
      \'coc-snippets',
      \'coc-pairs',
      \]


"Remove newbie crutches in Insert Mode
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>
inoremap <Up> <Nop>

" Remove newbie crutches in Normal Mode
nnoremap <Down> <Nop>
nnoremap <Left> <Nop>
nnoremap <Right> <Nop>
nnoremap <Up> <Nop>

" Remove newbie crutches in Visual Mode
vnoremap <Down> <Nop>
vnoremap <Left> <Nop>
vnoremap <Right> <Nop>
vnoremap <Up> <Nop>

" Rename tmux window name with the name of currently open file.
autocmd BufReadPost,FileReadPost,BufNewFile * call system("tmux rename-window " . expand("%:t"))
" Rename window again when vim exists
autocmd VimLeave * call system("tmux rename-window zsh")
" For coc.nvim
" TextEdit might fail if hidden is not set.
set hidden
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup
" Give more space for displaying messages.
set cmdheight=2
" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300
inoremap <silent><expr> <tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<tab>" :
      \ coc#refresh()
inoremap <silent><expr> <c-space> coc#refresh()
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction
" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif
" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

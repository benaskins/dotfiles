execute pathogen#infect()
syntax on
filetype plugin indent on

set t_Co=256
set background=dark
let g:solarized_termtrans = 1
colorscheme solarized

set clipboard=unnamed

set tabstop=2
set shiftwidth=2
set expandtab

set number

set timeoutlen=10000 ttimeoutlen=10

inoremap <Left>  <NOP>
inoremap <Right> <NOP>
inoremap <Up>    <NOP>
inoremap <Down>  <NOP>

" Insert current path in command mode
cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>

" Insert current file name in command mode
cmap <C-F> <C-R>=expand("%:p")<CR>

" \c - open a command to pipe the current file to the system clipboard
map <Leader>c :!more <C-R>=expand("%:p")<CR> \| pbcopy

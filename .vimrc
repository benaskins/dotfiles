" Lamina shell Vim config — clean, no nonsense

syntax on
set number            " show absolute line numbers
set norelativenumber  " disable relative lines
set nowrap            " don't wrap long lines
set tabstop=2
set shiftwidth=2
set expandtab
set smartindent
set cursorline
set scrolloff=5
set incsearch
set ignorecase
set smartcase
set clipboard=unnamedplus
set mouse=a
set background=dark   " assume a dark terminal, helps with contrast
colorscheme habamax

" Leader
let mapleader = ","

" Window nav like tmux
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Save with Ctrl-s
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a

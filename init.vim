" Default python provider
let g:python3_host_prog='/usr/bin/python3'
let g:loaded_python_provider = 0

let uname = substitute(system('uname'), '\n', '', '')
let sysname = substitute(system('uname -n'), '\n', '', '')
if uname == 'Darwin' && sysname == 'FHMac-GXJVX1R3GQ'
    let g:python3_host_prog='/Users/wochowicz/.pyenv/shims/python'
end
set guifont=Fira\ Mono,Liberation\ Mono:h11

set runtimepath^=~/.vim runtimepath+=~/.vim/after runtimepath+=~/.config/nvim/
if filereadable('~/.vimrc')
    source ~/.vimrc
endif

"Remap comma so that you can escape in terminal mode
tnoremap <C-S-,> <C-\>

if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
filetype plugin indent on
syntax enable

set magic
set ignorecase
set smartcase

set smarttab
set expandtab
set shiftwidth=4

set autochdir

let mapleader = ","
"Misc settings
nnoremap <Leader>e :tabnew ~/.config/nvim/init.vim<CR>
nnoremap <Leader>E :source ~/.config/nvim/init.vim<CR>
set hidden
"Shorter updatetime
set updatetime=1000
"remap the j/k keys for moving in menus
inoremap <A-j> <Down>
inoremap <A-k> <Up>
cnoremap <A-j> <Down>
cnoremap <A-k> <Up>
tnoremap <A-j> <Down>
tnoremap <A-k> <Up>

"NvimTree
nnoremap <silent> <F2> :NvimTreeToggle<CR>

" Put anything you want to happen only in Neovide here
if exists("g:neovide")
    nnoremap <F11> :let g:neovide_fullscreen = !g:neovide_fullscreen<CR>
    " lazy redraw causes issues with the cursor jumping all around in neovide
    set nolazyredraw
endif
"Telescope
nnoremap <leader>fm <cmd>Telescope marks<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>cc <cmd>Telescope git_commits<cr>
nnoremap <leader>cg <cmd>Telescope git_branches<cr>
nnoremap <leader>cb <cmd>Telescope git_bcommits<cr>

set number
set relativenumber

set mouse=""`
lua require('config')
lua require ('custom_commands')

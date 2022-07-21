set runtimepath^=~/.vim runtimepath+=~/.vim/after runtimepath+=~/.config/nvim/ runtimepath+=/home/manager/.cache/dein/repos/github.com/Shougo/dein.vim
let &packpath = &runtimepath
source ~/.vimrc

let g:python3_host_prog='/usr/bin/python3'
let g:loaded_python_provider = 0

"Remap comma so that you can escape in terminal mode
tnoremap <C-,> <C-\>

"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:

" Required:
call dein#begin('/home/manager/.cache/dein')

    " Let dein manage dein
    " Required:
    call dein#add('EdenEast/nightfox.nvim', {'rev' : 'v1.0.0'})
    call dein#add('nvim-lua/plenary.nvim')
    call dein#add('nvim-telescope/telescope.nvim', {'rev' : 'master'})
    call dein#add('nvim-telescope/telescope-fzf-native.nvim', { 'build': 'make' })
    call dein#add('/home/manager/.cache/dein/repos/github.com/Shougo/dein.vim')
    call dein#add('kyazdani42/nvim-tree.lua')
    lua require('nvim-tree').setup{}
    call dein#add('akinsho/toggleterm.nvim', {'rev' : 'v2.*'})
    lua require('toggleterm').setup{
    \   open_mapping = [[<C-\>]],
    \   direction = 'horizontal',
    \   size = 20
    \}
    call dein#add('neoclide/coc.nvim', {'rev' : 'release'})
    call dein#add('nvim-treesitter/nvim-treesitter', {'build' : ':TSUpdate'})
    call dein#add('ahmedkhalf/project.nvim')
    call dein#add('ahmedkhalf/lsp-rooter.nvim')

" Required:
call dein#end()

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts-------------------------

"Misc settings
colorscheme nightfox
set guifont=Liberation\ Mono:h11
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

"Telescope
"Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>cc <cmd>Telescope git_commits<cr>
nnoremap <leader>cg <cmd>Telescope git_branches<cr>

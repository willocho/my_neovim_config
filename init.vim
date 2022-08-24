"Check OS
let dein_path_base = ''
let uname = substitute(system('uname'), '\n', '', '')
if uname == 'Darwin'
    let dein_path_base = '/Users/willochowicz/'
elseif uname == 'Linux'
    let dein_path_base = '/home/manager/'
end

set guifont=Fira\ Mono,Liberation\ Mono:h11

let dein_path = dein_path_base . '.cache/dein/repos/github.com/Shougo/dein.vim'


set runtimepath^=~/.vim runtimepath+=~/.vim/after runtimepath+=~/.config/nvim/
exe 'set runtimepath+=' . dein_path
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
call dein#begin(dein_path)

    " Let dein manage dein
    call dein#add(dein_path)
    " Required:
    call dein#add('EdenEast/nightfox.nvim', {'rev' : 'v1.0.0'})
    call dein#add('nvim-lua/plenary.nvim')
    call dein#add('nvim-telescope/telescope.nvim', {'rev' : 'master'})
    call dein#add('nvim-telescope/telescope-fzf-native.nvim', { 'build': 'make' })
    call dein#add('kyazdani42/nvim-tree.lua')
    lua require('nvim-tree').setup{}
    call dein#add('akinsho/toggleterm.nvim', {'rev' : 'v2.*'})
    call dein#add('neoclide/coc.nvim', {'rev' : 'release'})
    call dein#add('nvim-treesitter/nvim-treesitter', {'build' : ':TSUpdate'})
    call dein#add('ahmedkhalf/project.nvim')
    call dein#add('ahmedkhalf/lsp-rooter.nvim')
    call dein#add('terrortylor/nvim-comment')

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
nnoremap <Leader>e :tabnew ~/.config/nvim/init.vim<CR>
nnoremap <Leader>E :source ~/.config/nvim/init.vim<CR>
set hidden
set foldmethod=syntax
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
    " Put anything you want to happen only in Neovide here
    nnoremap <F11> :let g:neovide_fullscreen = !g:neovide_fullscreen
    " lazy redraw causes issues in neovide
    set nolazyredraw
endif
"Telescope
"Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>cc <cmd>Telescope git_commits<cr>
nnoremap <leader>cg <cmd>Telescope git_branches<cr>
nnoremap <leader>cb <cmd>Telescope git_bcommits<cr>

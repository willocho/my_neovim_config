return {
    {'EdenEast/nightfox.nvim', },
    {'nvim-lua/plenary.nvim'},
    {'nvim-telescope/telescope.nvim', lazy = true},
    {'nvim-telescope/telescope-fzf-native.nvim', build='make', lazy = true },
    {'nvim-tree/nvim-tree.lua', opts={} },
    {'akinsho/toggleterm.nvim', lazy = true},
    {'nvim-treesitter/nvim-treesitter', build=':TSUpdate' },
    {'ahmedkhalf/project.nvim', lazy = true},
    {'terrortylor/nvim-comment', lazy = true},
    {'tpope/vim-fugitive',
        cmd = 'G',
        lazy = true
    },
    { 'tpope/vim-unimpaired' },
}

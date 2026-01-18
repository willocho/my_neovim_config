return {
    {'EdenEast/nightfox.nvim', },
    {'nvim-lua/plenary.nvim'},
    {'nvim-telescope/telescope.nvim', lazy = true},
    {'nvim-telescope/telescope-fzf-native.nvim', build='make', lazy = true },
    {'nvim-tree/nvim-tree.lua', opts={} },
    {'akinsho/toggleterm.nvim', lazy = true},
    {'nvim-treesitter/nvim-treesitter', build=':TSUpdate' },
    {
        'DrKJeff16/project.nvim',
        lazy = true,
        version = false, -- Get the latest release
        cmd = { -- Lazy-load by commands
            'Project',
            'ProjectAdd',
            'ProjectConfig',
            'ProjectDelete',
            'ProjectHistory',
            'ProjectRecents',
            'ProjectRoot',
            'ProjectSession',
        },
        dependencies = { -- OPTIONAL
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim',
            'ibhagwan/fzf-lua',
        },
        ---@module 'project'

        ---@type Project.Config.Options
        opts = {},
    },
    {'terrortylor/nvim-comment', lazy = true},
    {'tpope/vim-fugitive',
        cmd = 'G',
        lazy = true
    },
    { 'tpope/vim-unimpaired' },
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-buffer' },
    { 'neovim/nvim-lspconfig' },
}

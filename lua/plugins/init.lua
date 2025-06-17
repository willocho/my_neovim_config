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
    {'windwp/nvim-projectconfig', lazy = true},
    {'MrcJkb/haskell-tools.nvim', lazy = true},
    {'mfussenegger/nvim-dap', lazy = true},
    {'ThePrimeagen/harpoon', lazy = true},
    {'nvim-tree/nvim-web-devicons'},
    {'Olical/conjure',
        lazy = true,
        ft = { 'clojure' },
    },
    {
        'julienvincent/nvim-paredit',
        ft = { 'clojure', 'fennel', 'lisp', 'scheme'},
        lazy = true
    },
    {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = function()
        require('nvim-surround').setup({
            -- Configuration here, or leave empty to use defaults
        })
    end
    },
    { 'neovim/nvim-lspconfig', lazy = false },
    { 'folke/neodev.nvim', opts = {}, lazy = true, ft = { 'lua' }},
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-buffer' },
    { 'github/copilot.vim' }, --Github Copilot
    {
        "greggh/claude-code.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim", -- Required for git operations
        },
        config = function()
            require("claude-code").setup()
        end
    },
}

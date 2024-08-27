local actions = require('telescope.actions')
local telescope = require('telescope')

telescope.setup{ 
    opt = {
        pickers = {
            find_files = {
                find_command = {
                    'fd',
                    '--color=never',
                    '-H',
                }
            }
        },
        defaults = {
            mappings = {
                i = {
                    ["<A-j>"] = function () actions.move_selection_next(vim.api.nvim_get_current_buf()) end,
                    ["<A-k>"] = function () actions.move_selection_previous(vim.api.nvim_get_current_buf()) end,
                    ["<A-h>"] = function () vim.api.nvim_cmd({ cmd = "normal", args = {"h"}}, {}) end,
                    ["<A-l>"] = function () vim.api.nvim_cmd({ cmd = "normal", args = {"l"}}, {}) end,
                }
            },
            vimgrep_arguments = {
                'rg',
                '--color=never',
                '--no-heading',
                '--with-filename',
                '--line-number',
                '--column',
                '--smart-case',
            },
        }
    }
}

    vim.api.nvim_set_keymap('n', 'gp', ':Telescope projects<CR>', {})

    telescope.load_extension('projects')

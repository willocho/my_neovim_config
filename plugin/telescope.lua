local actions = require('telescope.actions')
local telescope = require('telescope')

telescope.setup{
    pickers = {
        find_files = {
            hidden = true,
            find_command = {
                'rg',
                '--color=never',
                '--files',
                '--no-ignore',
                '--iglob',
                '!.git',
                '--iglob',
                '!node_modules/**/*',
                '--iglob',
                '!.idea/',
                '--iglob',
                '!dist/'
            }
        }
    },
    defaults = {
        mappings = {
            i = {
                ["<A-j>"] = function () actions.move_selection_next(vim.api.nvim_get_current_buf()) end,
                ["<A-k>"] = function () actions.move_selection_previous(vim.api.nvim_get_current_buf()) end
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
            '--iglob',
            '!.git',
            '--iglob',
            '!node_modules/**/*',
            '--iglob',
            '!.idea/',
            '--iglob',
            '!dist/',
            '-u'
        },

    }
}

telescope.load_extension('projects')

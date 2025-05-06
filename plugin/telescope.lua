local actions = require('telescope.actions')
local telescope = require('telescope')

telescope.setup{
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
            -- '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
        },
    }
}

vim.api.nvim_set_keymap('n', 'gp', ':Telescope projects<CR>', {})

--Look at all files in the top level git directory
vim.keymap.set('n', '<Leader>F',
function ()
    local handle = io.popen('git rev-parse --show-toplevel')
    if handle ~= nil then
        local result_path = handle:read('*a')
        local result = {handle:close()}

        if result[1] and 
            (result[2] == "exit" or result[2] == nil) and
            (result[3] == 0 or result[3] == nil) then
            local builtin = require('telescope.builtin')
            --remove trailing newline
            result_path = result_path:gsub('\n', '')
            builtin.find_files{
                cwd = result_path,
                find_command = {
                    'fd',
                    '--color=never',
                    '-H',
                }
            }
        end
    end
end,
{}
)

--Grep from the top level git directory
vim.keymap.set('n', '<Leader>G',
function ()
    local handle = io.popen('git rev-parse --show-toplevel')
    if handle ~= nil then
        local result_path = handle:read('*a')
        local result = {handle:close()}

        if result[1] and 
            (result[2] == "exit" or result[2] == nil) and
            (result[3] == 0 or result[3] == nil) then
            local builtin = require('telescope.builtin')
            --remove trailing newline
            result_path = result_path:gsub('\n', '')
            builtin.live_grep{
                cwd = result_path,
                find_command = {
                  'rg',
                  -- '--color=never',
                  '--no-heading',
                  '--with-filename',
                  '--line-number',
                  '--column',
                  '--smart-case',
                }
            }
        end
    end
end,
{}
)

telescope.load_extension('projects')

local function get_git_directory()
    local handle = io.popen('git rev-parse --show-toplevel')
    if handle ~= nil then
        local result_path = handle:read('*a')
        local result = {handle:close()}

        if result[1] and
            (result[2] == "exit" or result[2] == nil) and
            (result[3] == 0 or result[3] == nil) then
            result_path = result_path:gsub('\n', '')
            return result_path
        else
            return nil
        end
    end
end

local function longest_matching_lsp_workspace_dir()
    -- Get the current buffer number
    local bufnr = vim.api.nvim_get_current_buf()

    -- Get the full path of the current buffer
    local file_path = vim.api.nvim_buf_get_name(bufnr)

    -- Get active LSP clients for the current buffer
    local clients = vim.lsp.get_clients({bufnr = bufnr})

    local longest_matching_workspace_path = nil

    -- Check each client's workspace folders
    for _, client in ipairs(clients) do
        if client.config and client.config.workspace_folders then
            for _, folder in ipairs(client.config.workspace_folders) do
                -- Convert URI to path if needed
                local workspace_path = folder.uri
                if workspace_path:find("^file://") then
                    workspace_path = workspace_path:gsub("^file://", "")
                    -- On Windows, remove leading slash
                    if vim.fn.has("win32") == 1 then
                        workspace_path = workspace_path:gsub("^/", "")
                    end
                end

                -- Check if file_path starts with workspace_path
                if vim.startswith(file_path, workspace_path)
                    and (longest_matching_workspace_path == nil
                        or string.len(workspace_path) > string.len(longest_matching_workspace_path)) then
                    longest_matching_workspace_path = workspace_path
                end
            end
        end
        if client.config and client.config.root_dir then
            -- Check if file_path starts with root_dir
            local root_dir = client.config.root_dir
            if vim.startswith(file_path, root_dir)
                and (longest_matching_workspace_path == nil
                    or string.len(root_dir) > string.len(longest_matching_workspace_path)) then
                longest_matching_workspace_path = root_dir
            end
        end
    end
    return longest_matching_workspace_path
end

function LSP_aware_file_grep()
    local _longest_matching_lsp_workspace_dir = longest_matching_lsp_workspace_dir()

    local builtin = require('telescope.builtin')
    if _longest_matching_lsp_workspace_dir then
        builtin.live_grep{
            cwd = _longest_matching_lsp_workspace_dir,
        }
    else
        local git_dir = get_git_directory()
        if git_dir then
            builtin.live_grep{
                cwd = git_dir,
            }
        else
            builtin.live_grep()
        end
    end
end

function LSP_aware_file_search()
    local _longest_matching_lsp_workspace_dir = longest_matching_lsp_workspace_dir()

    local builtin = require('telescope.builtin')
    if _longest_matching_lsp_workspace_dir then
        builtin.find_files{
            cwd = _longest_matching_lsp_workspace_dir,
        }
    else
        local git_dir = get_git_directory()
        if git_dir then
            builtin.find_files{
                cwd = git_dir,
            }
        else
            builtin.find_files()
        end
    end
end

vim.keymap.set('n', '<leader>fg', LSP_aware_file_grep)
vim.keymap.set('n', '<leader>ff', LSP_aware_file_search)

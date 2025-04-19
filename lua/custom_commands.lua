local setup_pyright = function ()
    local cjson = require'cjson'
    local buffer = vim.api.nvim_get_current_buf()
    local client = vim.lsp.get_clients({ name = 'pyright', bufnr = buffer })[1]
    if client then
        if client.supports_method(vim.lsp.protocol.Methods.workspace_didChangeConfiguration) then
        local file = io.open("/Users/wochowicz/Local_Repository/src/pyrightconfig.json", "r")
        if file then
            local content = file:read("*all")
            file:close()
            ---@type table
            content = cjson.decode(content)
            print(content)
            if client.settings then
                client.settings.root_dir = "/Users/wochowicz/Local_Repository/src/"
            else
                client.config.settings.root_dir = "/Users/wochowicz/Local_Repository/src/"
            end
            client.notify(
                vim.lsp.protocol.Methods.workspace_didChangeConfiguration,
                { settings = nil }
            )
        else
            print("Failed to open config")
        end
        else
            print("Client doesn't support method")
        end
    else
        print("Client not found")
    end
end

vim.keymap.set('n', '<leader>ps', setup_pyright)

vim.g.mapleader = ","
vim.g.maplocalleader = " "

vim.keymap.set('n', 'g/', ':let @/ = ""<CR>', {silent = true})


require("config.lazy")

local nvimtree = require('nvim-tree.api')
vim.keymap.set({'n', 'v', 'i'},
    '<A-f>',
    function ()
        nvimtree.tree.find_file{
        open = true,
        focus = true,
        update_root = true
    }
    end
)

vim.cmd("colorscheme nightfox")

-------------------- LSP Stuff --------------------- -
vim.lsp.enable('basedpyright')

vim.lsp.config('basedpyright', {
    root_markers = {{'pyproject.toml', 'poetry.lock'}, 'requirements.txt', '.git'}
})

vim.lsp.config("lua_ls", {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
    telemetry = { enabled = true },
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" }},
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true)},
            }}})
vim.lsp.enable('lua_ls')

vim.lsp.config('ts_ls', {})
vim.lsp.enable('ts_ls')
vim.lsp.config('rust_analyzer', {})
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('beancount')
vim.lsp.enable('clojure_lsp')

-------------------------- Autocompletion -------------------------------------------
local cmp = require'cmp'
cmp.setup{
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
    },
    mapping = cmp.mapping.preset.insert({
        ["<CR>"] = cmp.mapping(
            function(fallback)
                if cmp.visible() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
                else
                    fallback()
                end
            end
        , {'i', 's'}
    ),
        ["<Tab>"] = cmp.mapping(
            function(fallback)
                if cmp.visible() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
                else
                    fallback()
                end
            end
        ,{'i', 's'}
    ),
    }),
}


-------------------- A Bunch of LSP Commands and Autocommands -----------------------
vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>a', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          --Go back and forth to find errors
          map('[g', vim.diagnostic.goto_prev, '[G]oto Previous Diagnostic')
          map(']g', vim.diagnostic.goto_next, '[G]oto Previous Diagnostic')

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })


-- Set shiftwidth for JS, JSX, TS, TSX files
local default_shiftwidth = 4

-- Store original values when entering JS/TS files
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  pattern = {"*.js", "*.jsx", "*.ts", "*.tsx"},
  callback = function()
    -- Set the shiftwidth to 2 (or your preferred value)
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true

    -- Optional: Print confirmation message
    -- print("JavaScript/TypeScript settings applied: shiftwidth=2")
  end,
  desc = "Set shiftwidth for JavaScript and TypeScript files"
})

-- Reset to default values when leaving JS/TS files
vim.api.nvim_create_autocmd({"BufLeave"}, {
  pattern = {"*.js", "*.jsx", "*.ts", "*.tsx"},
  callback = function()
    -- Reset back to default value
    vim.opt_local.shiftwidth = default_shiftwidth
    vim.opt_local.tabstop = default_shiftwidth
    -- Keep expandtab as is, or change if needed

    -- Optional: Print confirmation message
    -- print("Reset to default settings: shiftwidth=" .. default_shiftwidth)
  end,
  desc = "Reset shiftwidth when leaving JavaScript and TypeScript files"
})


--Conjure configuration
vim.g["conjure#mapping#doc_word"] = "gk"

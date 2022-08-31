local termTable = require('toggleterm.terminal')
local ui = require('toggleterm.ui')
    --Source zprofile and use npm 12 by default for compiling work projects
require('toggleterm').setup{
    open_mapping = [[<C-\>]],
    direction = 'horizontal',
    size = 20,
    on_open = function (term)
        if term._Opened == nil or term._Opened == false then 
            local handle = io.popen("uname")
            local result = handle:read("*a")
            handle:close()
            if string.match(result, "Darwin") then
                term:send("source ~/.zprofile")
            end
            term:send({ "nvm use 12", "clear" })
        end
        term._Opened = true
    end,
}

local Terminal = termTable.Terminal

local _lazygit_buffer_id = 99
local _event_sim_node_buffer_id = 100

--Ensure lazygit always opens the repo of the current directory
function _lazygit_toggle()
    local term = termTable:get(_lazygit_buffer_id)
    if term ~= nil then
        term:toggle()
        do return end
    end
    local current = vim.fn.getcwd()
    local lazygit = Terminal:new({
        id = _lazygit_buffer_id,
        cmd = "lazygit",
        direction = 'float',
        float_opts = {
            border = "double"
        },
        --Skip the on_open function defined in init.vim
        on_open = function () end,
        dir = current,
    })
    lazygit:toggle()
end

vim.keymap.set("n", "<leader>g1", _lazygit_toggle, {noremap = true, silent = true})

local event_sim = Terminal:new({
    id = _event_sim_node_buffer_id,
    dir = "~/Local_Repository/event_sim_node/",
    cmd = "npm run start",
    direction = "float",
    float_opts = {
        border = "double"
    },
    start_in_insert = false
})

function _event_sim_toggle()
    event_sim:toggle()
end

vim.keymap.set("n", "<leader>g2", _event_sim_toggle, {noremap = true, silent = true})

function _current_terminal()
    local terms = termTable.get_all()
    local current_buffer_id = vim.api.nvim_get_current_buf()
    for _, term in pairs(terms) do
        if term.bufnr == current_buffer_id then return term end
    end
end

function _get_next_terminal_buffer()
    local terms = termTable.get_all()
    table.sort(terms, function(a, b) return a.id < b.id end)
    local current_terminal = _current_terminal()
    local next_terminal = terms[1]
    for i, term in pairs(terms) do
        if term.id > current_terminal.id then next_terminal = term; break; end
    end
    ui.switch_buf(next_terminal.bufnr)
end

function _get_previous_terminal_buffer()
    local terms = termTable.get_all()
    table.sort(terms, function(a, b) return a.id < b.id end)
    local current_terminal = _current_terminal()
    local next_terminal = terms[#terms]
    for i, term in pairs(terms) do
        if term.id < current_terminal.id then next_terminal = term end
    end
    ui.switch_buf(next_terminal.bufnr)
end

vim.keymap.set('t', '<A-h>', _get_previous_terminal_buffer, {})
vim.keymap.set('t', '<A-l>', _get_next_terminal_buffer, {})

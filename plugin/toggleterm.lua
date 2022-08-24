local termTable = require('toggleterm.terminal')
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

vim.api.nvim_set_keymap("n", "<leader>g1", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true})

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

vim.api.nvim_set_keymap("n", "<leader>g2", "<cmd>lua _event_sim_toggle()<CR>", {noremap = true, silent = true})

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

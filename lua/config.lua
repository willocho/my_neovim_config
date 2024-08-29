vim.g.mapleader = ","
vim.g.maplocalleader = " "
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  pattern = {"Justfile"},
  callback = function(_)
      vim.api.nvim_set_option_value('expandtab', false, {})
  end
})

vim.api.nvim_create_autocmd({"BufLeave", "BufWinLeave"}, {
  pattern = {"Justfile"},
  callback = function(_)
      vim.api.nvim_set_option_value('expandtab', true, {})
  end
})

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

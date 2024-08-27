vim.g.mapleader = ","
vim.g.maplocalleader = " "
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  pattern = {"Justfile"},
  callback = function(ev)
      vim.api.nvim_set_option_value('expandtab', false, {})
  end
})

vim.api.nvim_create_autocmd({"BufLeave", "BufWinLeave"}, {
  pattern = {"Justfile"},
  callback = function(ev)
      vim.api.nvim_set_option_value('expandtab', true, {})
  end
})
require("config.lazy")

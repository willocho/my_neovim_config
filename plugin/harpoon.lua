local ui = require('harpoon.ui')
local mark = require('harpoon.mark')

vim.keymap.set('n', '<Leader>hh', ui.toggle_quick_menu, {})
vim.keymap.set('n', '<Leader>hm', mark.add_file, {})
vim.keymap.set('n', '<Leader>hf', mark.store_offset, {})


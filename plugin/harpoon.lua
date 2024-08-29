local ui = require('harpoon.ui')
local mark = require('harpoon.mark')

vim.keymap.set('n', '<Leader>h', ui.toggle_quick_menu, {})
vim.keymap.set('n', '<Leader>m', mark.add_file, {})


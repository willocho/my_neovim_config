vim.keymap.set('n', "<leader>r", ':MagmaEvaluateOperator<CR>', {noremap = true, silent = true})
vim.keymap.set('n', "<leader>rr", ':MagmaEvaluateLine<CR>', {noremap = true, silent = true})
vim.keymap.set('x', "<leader>r", ':<C-u>MagmaEvaluateVisual<CR>', {noremap = true, silent = true})
vim.keymap.set('n', "<leader>rc", ':MagmaReevaluateCell<CR>', {noremap = true, silent = true})

vim.cmd('let g:magma_automatically_open_output = v:false')
vim.cmd('let g:magma_image_provider = "ueberzug"')

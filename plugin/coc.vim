"Coc Settings
" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation split (lowercase)
nmap <silent> <Leader>gd :call CocAction('jumpDefinition', 'vsplit')<CR>
nmap <silent> <Leader>gy :call CocAction('jumpTypeDefinition', 'vsplit')<CR>
nmap <silent> <Leader>gi :call CocAction('jumpImplementation', 'vsplit')<CR>
" GoTo code navigation with default (uppercase)
nmap <silent> <Leader>gD :call CocAction('jumpDefinition')<CR>
nmap <silent> <Leader>gY :call CocAction('jumpTypeDefinition')<CR>
nmap <silent> <Leader>gI :call CocAction('jumpImplementation')<CR>
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Remap for do codeAction of current line
xmap <leader>a  <Plug>(coc-codeaction-line)
nmap <leader>a  <Plug>(coc-codeaction-line)

inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

inoremap <expr> <A-j> coc#pum#visible() ? coc#pum#next(1) : "\<Down>"
inoremap <expr> <A-k> coc#pum#visible() ? coc#pum#prev(1) : "\<Up>"

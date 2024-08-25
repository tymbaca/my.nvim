set nocompatible
filetype plugin on
syntax on

function! s:Camelize(range) abort
  if a:range == 0
    s#\(\%(\<\l\+\)\%(_\)\@=\)\|_\(\l\)#\u\1\2#g
  else
    s#\%V\(\%(\<\l\+\)\%(_\)\@=\)\|_\(\l\)\%V#\u\1\2#g
  endif
endfunction

function! s:Snakeize(range) abort
  if a:range == 0
    s#\C\(\<\u[a-z0-9]\+\|[a-z0-9]\+\)\(\u\)#\l\1_\l\2#g
  else
    s#\%V\C\(\<\u[a-z0-9]\+\|[a-z0-9]\+\)\(\u\)\%V#\l\1_\l\2#g
  endif
endfunction

command! -range CamelCase silent! call <SID>Camelize(<range>)
command! -range SnakeCase silent! call <SID>Snakeize(<range>)

set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

autocmd FileType python setlocal tabstop=4
autocmd FileType python setlocal softtabstop=4
autocmd FileType python setlocal shiftwidth=4

autocmd FileType typescriptreact setlocal tabstop=2
autocmd FileType typescriptreact setlocal softtabstop=2
autocmd FileType typescriptreact setlocal shiftwidth=2

autocmd FileType typescript setlocal tabstop=2
autocmd FileType typescript setlocal softtabstop=2
autocmd FileType typescript setlocal shiftwidth=2

autocmd FileType go setlocal tabstop=8
autocmd FileType go setlocal softtabstop=8
autocmd FileType go setlocal shiftwidth=8

autocmd FileType templ setlocal tabstop=8
autocmd FileType templ setlocal softtabstop=8
autocmd FileType templ setlocal shiftwidth=8

autocmd FileType proto setlocal tabstop=2
autocmd FileType proto setlocal softtabstop=2
autocmd FileType proto setlocal shiftwidth=2

autocmd FileType html setlocal tabstop=2
autocmd FileType html setlocal softtabstop=2
autocmd FileType html setlocal shiftwidth=2

autocmd FileType css setlocal tabstop=2
autocmd FileType css setlocal softtabstop=2
autocmd FileType css setlocal shiftwidth=2

autocmd FileType markdown setlocal wrap
autocmd FileType markdown setlocal formatoptions=tcqjwa
au FileType markdown setl comments=b:*,b:-,b:+,n:>
au FileType markdown setl formatoptions+=r

autocmd FileType vimwiki setlocal wrap
autocmd FileType vimwiki setlocal formatoptions=tcqjwa

autocmd FileType lua setlocal tabstop=2
autocmd FileType lua setlocal softtabstop=2
autocmd FileType lua setlocal shiftwidth=2

autocmd FileType tsv setlocal noexpandtab
autocmd FileType tsv setlocal tabstop=8
autocmd FileType tsv setlocal shiftwidth=8

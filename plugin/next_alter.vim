"=============================================================================
" File: next-alter.vim
" Author: mopp
" Created: 2014-03-01
"=============================================================================


scriptencoding utf-8
if exists('g:loaded_next_alter')
    finish
endif
let g:loaded_next_alter = 1

let s:save_cpo = &cpo
set cpo&vim


nnoremap <silent> <Plug>(next-alter-open) :<C-u>call next_alter#open_alter_file()<CR>
command! OpenNAlter call next_alter#open_alter_file()


let &cpo = s:save_cpo
unlet s:save_cpo

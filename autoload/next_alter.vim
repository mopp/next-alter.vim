"=============================================================================
" File: next-alter.vim
" Author: mopp
" Created: 2014-03-01
"=============================================================================
scriptencoding utf-8

if !exists('g:loaded_next_alter')
    runtime! plugin/next_alter.vim
endif
let g:loaded_next_alter = 1

let s:save_cpo = &cpo
set cpo&vim

" extension : alternate extension
let s:default_pair_extension = {
            \ 'c'   : [ 'h' ],
            \ 'C'   : [ 'H' ],
            \ 'cc'  : [ 'h' ],
            \ 'CC'  : [ 'H', 'h'],
            \ 'cpp' : [ 'h', 'hpp' ],
            \ 'CPP' : [ 'H', 'HPP' ],
            \ 'cxx' : [ 'h', 'hpp' ],
            \ 'CXX' : [ 'H', 'HPP' ],
            \ 'h'   : [ 'c', 'cpp', 'cxx' ],
            \ 'H'   : [ 'C', 'CPP', 'CXX' ],
            \ 'hpp' : [ 'cpp', 'cxx'],
            \ 'HPP' : [ 'CPP', 'CXX'],
            \ }
let s:default_search_dir = [ '.' , '..', './include', '../include' ]

let g:next_alter#pair_extension = get(g:, 'next_alter#pair_extension', s:default_pair_extension)
let g:next_alter#search_dir = get(g:, 'next_alter#search_dir', s:default_search_dir)
let g:next_alter#open_option = get(g:, 'next_alter#open_option', '')


" returns current file infomation in dictionary.
function! s:get_current_file_info()
    return { 'path' : expand('%:p:h'), 'file_name' : expand('%:t:r'), 'extension' : expand('%:e') }
endfunction


" find argument in exists buffer.
function! s:find_buffer(file_path)
    return bufname(fnamemodify(a:file_path, ':t'))
endfunction


" return alternate file path in vim file.
function! s:get_vim_alter_filepath()
    let info = s:get_current_file_info()
    let directory = expand('%:p:h:t')

    if directory == 'autoload'
        return expand('%:p:h') . '/../plugin/' . expand('%:t')
    elseif directory == 'plugin'
        return expand('%:p:h') . '/../autoload/' . expand('%:t')
    else
        return ''
    endif
endfunction


" return alternate file path.
function! s:get_alter_filepath()
    let info = s:get_current_file_info()
    let e = info['extension']
    let t = values(filter(deepcopy(g:next_alter#pair_extension), 'v:key ==# ' . string(e)))

    if len(t) == 0
        return ''
    endif

    let candidates = []

    for i in t
        for j in i
            let alter_name = info['file_name'] . '.' . j
            for k in g:next_alter#search_dir
                let alter_file_path = k . '/' . alter_name
                call add(candidates, alter_file_path)
            endfor
            unlet k
        endfor
        unlet j
    endfor
    unlet i

    return candidates
endfunction


" open buffer with option.
function! s:open_buffer(target)
    if g:next_alter#open_option == ''
        execute 'edit' a:target
    else
        execute g:next_alter#open_option 'split' a:target
    endif
endfunction


" open buffer only vim file.
function! s:open_vim()
    let target = s:get_vim_alter_filepath()

    if target == ''
        echoerr 'cannot open alternate vim file.'
        return
    endif

    call s:open_buffer(target)

    if !filereadable(target)
        redraw
        echomsg 'created ' . target
    endif
endfunction


" open buffer.
function! s:open()
    if !has_key(g:next_alter#pair_extension, s:get_current_file_info()['extension'])
        echoerr 'Pair extension file NOT exists in setting.'
        return
    endif

    let alter_file_paths = s:get_alter_filepath()

    if len(alter_file_paths) == 0
        echoerr 'Alternate File is NOT Found !'
        return
    endif

    " check is file already exists ?
    for i in alter_file_paths
        let target = filereadable(i) ? i : s:find_buffer(i)

        if target != ''
            break
        endif
    endfor

    let f = 0
    if target == ''
        let target = alter_file_paths[0]
        let f = 1
    endif

    call s:open_buffer(target)

    if f == 1
        redraw
        echomsg 'cannot detect alternate file.'
        echomsg 'created ' . target
    endif
endfunction


" open alternate filepath
function! next_alter#open_alter_file()
    let e = s:get_current_file_info()['extension']

    if e == 'vim' || &filetype == 'vim'
        call s:open_vim()
    else
        call s:open()
    endif
endfunction


" open alternate filepath with option.
function! next_alter#open_alter_file_option(cmd_arg)
    if type(a:cmd_arg) != type('')
        echoerr 'Command argument is invalid !'
        return
    endif

    let store = g:next_alter#open_option
    let g:next_alter#open_option = a:cmd_arg

    call next_alter#open_alter_file()

    let g:next_alter#open_option = store
endfunction


" complete command argumetn.
function! next_alter#complete(arg_lead, cmd_line, cursor_pos)
    return filter([ 'vertical', 'aboveleft', 'belowright', 'topleft', 'botright', ], "v:val =~? '^" . a:arg_lead . ".*'")
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

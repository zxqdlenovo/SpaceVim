let s:JOB = SpaceVim#api#import('job')

let s:rst = []

function! SpaceVim#plugins#searcher#find(expr, exe)
    if empty(a:expr)
        let expr = input('search expr: ')
    else
        let expr = a:expr
    endif
    call s:JOB.start(s:get_search_cmd(a:exe, expr), {
                \ 'on_stdout' : function('s:search_stdout'),
                \ 'in_io' : 'null',
                \ 'on_exit' : function('s:search_exit'),
                \ })
endfunction
function! s:search_stdout(id, data, event) abort
    for data in a:data
        let info = split(data, '\:\d\+\:')
        if len(info) == 2
            let [fname, text] = info
            let lnum = matchstr(data, '\:\d\+\:')[1:-2]
            call add(s:rst, {
                        \ 'filename' : fnamemodify(fname, ':p'),
                        \ 'lnum' : lnum,
                        \ 'text' : text,
                        \ })
        endif
    endfor
endfunction

function! s:get_search_cmd(exe, expr) abort
    if a:exe == 'grep'
        return ['grep', '-inHR', '--exclude-dir', '.git', a:expr, '.']
    elseif a:exe == 'rg'
        return ['rg', '-n', a:expr]
    else
        return [a:exe, a:expr]
    endif
endfunction

function! s:search_exit(id, data, event) abort
    let &l:statusline = SpaceVim#layers#core#statusline#get(1)
endfunction


function! SpaceVim#plugins#searcher#list()
    call setqflist(s:rst)
    let s:rst = []
    copen
endfunction

function! SpaceVim#plugins#searcher#count()
    if empty(s:rst)
        return ''
    else
        return ' ' . len(s:rst) . ' items '
    endif
endfunction



" Author: Devon Meunier <devon.meunier@gmail.com>
" Description: checkstyle for Java files

function! ale_linters#java#checkstyle#Handle(buffer, lines) abort
    let l:output = []

    " modern checkstyle versions
    let l:pattern = '\v\[(WARN|ERROR)\] [a-zA-Z]?:?[^:]+:(\d+):(\d+)?:? (.*) \[(.+)\]$'

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'type': l:match[1] is? 'WARN' ? 'W' : 'E',
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': l:match[4],
        \   'code': l:match[5],
        \})
    endfor

    if !empty(l:output)
        return l:output
    endif

    " old checkstyle versions
    let l:pattern = '\v(.+):(\d+): ([^:]+): (.+)$'

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'type': l:match[3] is? 'warning' ? 'W' : 'E',
        \   'lnum': l:match[2] + 0,
        \   'text': l:match[4],
        \})
    endfor

    return l:output
endfunction

function! ale_linters#java#checkstyle#GetCommand(buffer) abort
    return 'checkstyle '
    \ . ale#Var(a:buffer, 'java_checkstyle_options')
    \ . ' %s'
endfunction

if !exists('g:ale_java_checkstyle_options')
    let g:ale_java_checkstyle_options = '-c /google_checks.xml'
endif

call ale#linter#Define('java', {
\   'name': 'checkstyle',
\   'executable': 'checkstyle',
\   'command': function('ale_linters#java#checkstyle#GetCommand'),
\   'callback': 'ale_linters#java#checkstyle#Handle',
\   'lint_file': 1,
\})

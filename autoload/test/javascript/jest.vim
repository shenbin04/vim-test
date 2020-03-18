if !exists('g:test#javascript#jest#file_pattern')
  let g:test#javascript#jest#file_pattern = '\v(__tests__/.*|(spec|test))\.(js|jsx|coffee|ts|tsx)$'
endif

function! test#javascript#jest#test_file(file) abort
  return a:file =~# g:test#javascript#jest#file_pattern
    \ && test#javascript#has_package('jest')
endfunction

function! test#javascript#jest#build_position(type, position) abort
  if a:type ==# 'nearest'
    let name = s:nearest_test(a:position)
    if !empty(name)
      let name = '-t '.shellescape(name, 1)
    endif
    return ['--no-coverage', name, '--', a:position['file']]
  elseif a:type ==# 'file'
    return ['--', a:position['file']]
  else
    return []
  endif
endfunction

let s:yarn_command = '\<yarn\>'
function! test#javascript#jest#build_args(args) abort
  let args = a:args
  if exists('g:test#javascript#jest#executable')
    \ && g:test#javascript#jest#executable =~# s:yarn_command
    let args = filter(a:args, 'v:val != "--"')
  endif

  if !get(g:, 'test#javascript#jest#cache', 1)
    call insert(args, '--no-cache')
  endif

  if get(g:, 'test#javascript#jest#coverage', 1)
    call insert(args, '--coverage')
  endif

  if get(g:, 'test#javascript#jest#project', 0)
    let config = findfile('jest.config.js', '.;')
    if len(config)
      let args = ['--projects', fnamemodify(config, ':.:h')] + args
    endif
  endif

  return args
endfunction

function! test#javascript#jest#executable() abort
  if filereadable('node_modules/.bin/jest')
    return 'node_modules/.bin/jest'
  else
    return 'jest'
  endif
endfunction

function! s:nearest_test(position) abort
  let name = test#base#nearest_test(a:position, g:test#javascript#patterns)
  return (len(name['namespace']) ? '^' : '') .
       \ test#base#escape_regex(join(name['namespace'] + name['test'])) .
       \ (len(name['test']) ? '$' : '')
endfunction

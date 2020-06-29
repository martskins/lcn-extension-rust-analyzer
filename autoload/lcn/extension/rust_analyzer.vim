function! lcn#extension#rust_analyzer#supported_commands() abort
  return ['rust-analyzer.runSingle', 'rust-analyzer.run', 'rust-analyzer.applySourceChange']
endfunction

" { command:string, arguments:any }
function! lcn#extension#rust_analyzer#execute_command(command) abort
  let l:command = json_decode(a:command)
  if !has_key(l:command, 'command')
    return
  endif

  let l:command_name = l:command['command']
  if l:command_name ==# 'rust-analyzer.runSingle'
    return s:RunSingle(l:command)
  elseif l:command_name ==# 'rust-analyzer.run'
    return s:Run(l:command)
  elseif l:command_name ==# 'rust-analyzer.applySourceChange'
    return s:ApplySourceChange(l:command)
  elseif l:command_name ==# 'rust-analyzer.showReferences'
    return s:ShowReferences(l:command)
  endif
endfunction

" runs a binary target in a terminal
function! s:Run(command) abort
  return s:run_command(a:command)
endfunction

" runs a single test target in a terminal
function! s:RunSingle(command) abort
  return s:run_command(a:command)
endfunction

function! s:ApplySourceChange(command) abort
  if !has_key(a:command, 'arguments')
    return
  endif

  echom json_encode(a:command['arguments'])
  call LanguageClient#applyWorkspaceEdit(a:command['arguments'])
endfunction

function! s:ShowReferences(command) abort
  if !has_key(a:command, 'arguments')
    return
  endif

  if len(a:command['arguments']) < 3
    return
  endif

  call LanguageClient#presentList(a:command['arguments'][2])
endfunction

function! s:run_command(command) abort
  if !has_key(a:command, 'arguments')
    return
  endif

  if len(a:command['arguments']) ==# 0
    return
  endif

  let l:arguments = a:command['arguments'][0]
  let l:bin = 'cargo'
  if has_key(l:arguments, 'bin')
    let l:bin = l:arguments['bin']
  endif

  let l:args = []
  if has_key(l:arguments, 'args') && has_key(l:arguments['args'], 'cargoArgs')
    let l:args = l:arguments['args']['cargoArgs']
  elseif
  endif

  execute('term ' . l:bin . ' ' . join(l:args, ' '))
endfunction


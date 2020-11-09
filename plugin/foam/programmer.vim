" foam-programmer.txt - Useful Vim settings for working with OpenFOAM
" Maintainer: Matthew C. Jones
" Version:    1.0

" Script Variables {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"- Regular expression that matches an OpenFOAM makefile include file
"- Example: -I$(LIB_SRC)/transportModels \ 
let s:re_foamincludefile='\v\s*\zs-I[A-Z_)($]*\/(\w+|\/)+\ze[^-]*'
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Commands {{{1
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"- Parse OpenFOAM makefile included file into Vim-readable file
function! foam#programmer#parse_include_expr(fname)
  "- See $WM_PROJECT_DIR/wmake/makefiles/general
  let l:fname = substitute(a:fname,'-I','','g')
  let l:fname = substitute(l:fname,'$(LIB_SRC)','$FOAM_SRC','g')
  let l:fname = substitute(l:fname,'$(FOAM_APP)','$FOAM_APP','g')
  return l:fname
endfunction

"- Add OpenFOAM Make/options files to Vim path
"- Allows for searching path with [_CTRL-i, [_CTRL-d, CTRL-w_i, CTRL-w_d, etc.
function! s:ParseFoamMakefile(...)
  let l:filecwd = expand('%:p:h')
  let l:makefile = a:0==0 ? l:filecwd . '/Make/options' : a:1
  echom "Building path from linked files in " . l:makefile
  for l:line in readfile(l:makefile)
    let l:line = substitute(l:line,'\s+',' ','g')  " remove extra spaces
    let l:words = split(l:line,' ')  " split line into words
    for l:word in l:words
      let l:match = matchstr(l:word,s:re_foamincludefile)
      if strlen(l:match)  " if OpenFOAM include file is matched
        let l:fname = foam#programmer#parse_include_expr(l:match)
        execute "set path+=" . l:fname
      endif
    endfor
  endfor
endfunction
command! -nargs=? -complete=file FoamParseMakeFile
    \ call s:ParseFoamMakefile(<q-args>)

"- Build ctags using current directory and source files; DEP: Ctags
"- Use g] Ctrl-] and Ctrl-t to navigate through the tags
let g:ctags_options = "--totals --fields=+l"

"- Reference entire source code
function! s:BuildCtags()
  let l:find_cmd = "find . $FOAM_SRC $FOAM_APP $FOAM_ETC -name \\'*.[CH]\\'"
      \ . " -not -path '*lnInclude*'"
  let l:ctags_cmd = "ctags -L -"
  execute '!eval ' . l:find_cmd . ' \| ' . l:ctags_cmd . " " . g:ctags_options
endfunction
command! FoamCtags call s:BuildCtags()

"- Reference source code based on makefile linked files
function! s:BuildCtagsPrecise()
  let l:find_cmd = "find . \$(cat Make/options \| grep '\\-I' \|"
      \ . " tr -d ' \\\\' \| sed 's/-I/ /g' \|"
      \ . " sed 's/$(LIB_SRC)/$FOAM_SRC/g') -name \\'*.[CH]\\'"
  let l:ctags_cmd = "ctags -L -"
  execute '!eval ' . l:find_cmd . ' \| ' . l:ctags_cmd . " " . g:ctags_options
endfunction
command! FoamCtagsPrecise call s:BuildCtagsPrecise()
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" }}}1

" Autocommands {{{1
" -----------------------------------------------------------------------------
"- Detect OpenFOAM filetype
function! s:CheckFoamFileType()
  for nL in range(1,10)  " loop through the first 10 lines
    if (getline(nL) =~ 'FoamFile' || getline(nL) =~ '\\      /  F ield')
      setfiletype cpp
      set path+=$FOAM_ETC
      break
    endif
  endfor
endfunction

" Set settings to recognize linked file paths in OpenFOAM makefile
function! s:FoamIncludeSettings()
  " Need to backslash backslashes '\' and pipes '|' here
  let l:re_foamincludefile = substitute(s:re_foamincludefile,'\\','\\\\','g')
  let l:re_foamincludefile = substitute(l:re_foamincludefile,'|','\\|','g')
  execute "setlocal include=" . l:re_foamincludefile
  setlocal includeexpr=foam#programmer#parse_include_expr(v:fname)
endfunction

augroup FOAMCmds
  autocmd!
  autocmd BufRead * call s:CheckFoamFileType()
  autocmd BufRead files,options setfiletype foam_make | setlocal syntax=make
      \ | call s:FoamIncludeSettings()
      \ | silent! call s:ParseFoamMakefile()

  "- Set OpenFOAM files to cpp syntax
  if !exists('g:foam#programmer#syntax')
    let g:foam#programmer#syntax = v:false
  endif
  if g:foam#programmer#syntax
    autocmd FileType cpp silent! call s:ParseFoamMakefile()
  endif
augroup End
" -----------------------------------------------------------------------------
" }}}1

" Filetype settings for Fennel
" Location: ~/.config/nvim/ftplugin/fennel.vim

if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

setlocal comments=:;;,:;
setlocal commentstring=;\ %s
setlocal formatoptions-=t formatoptions+=croql

" treat fennel symbols as single words for w/b/*/gd
setlocal iskeyword=@,48-57,_,33,35-38,42,43,45-47,58,60-63,94,126

" built-in lisp indenting: good enough for a lisp without a dedicated indenter
setlocal lisp
setlocal lispwords=fn,lambda,let,local,var,global,if,when,do,while,for,each,match,match-try,case,case-try,with-open,doto,collect,icollect,accumulate,fcollect,faccumulate,macro,macros,eval-compiler
setlocal shiftwidth=2 softtabstop=2 expandtab

let b:undo_ftplugin = 'setlocal comments< commentstring< formatoptions< iskeyword< lisp< lispwords< shiftwidth< softtabstop< expandtab<'


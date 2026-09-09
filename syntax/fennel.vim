" Vim syntax file for Fennel (https://fennel-lang.org)
" Location: ~/.config/nvim/syntax/fennel.vim
" Neovim already detects *.fnl as filetype=fennel, so this file is all that is
" needed to get highlighting: :syntax is loaded from the first syntax/<ft>.vim
" found on 'runtimepath'.

if exists('b:current_syntax')
  finish
endif

" Fennel symbols may contain many characters that Vim does not consider part of
" a word by default. Numbers below are ASCII codes:
"   33 ! 35 # 36 $ 37 % 38 & 42 * 43 + 45 - 46 . 47 / 58 : 60 < 61 = 62 > 63 ?
"   94 ^ 126 ~
syn iskeyword @,48-57,_,33,35-38,42,43,45-47,58,60-63,94,126

" ---------------------------------------------------------------- comments --
syn keyword fennelTodo contained TODO FIXME XXX NOTE HACK
syn match   fennelComment ";.*$" contains=fennelTodo,@Spell
syn match   fennelShebang "\%^#!.*$"

" ----------------------------------------------------------------- strings --
syn match  fennelStringEscape contained "\\\%(x\x\{2}\|z\|\d\{1,3}\|u{\x\+}\|[\\abfnrtv'\"]\)"
syn region fennelString start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=fennelStringEscape,@Spell

" ----------------------------------------------------------------- numbers --
syn match fennelNumber "\<-\=\d\+\%(\.\d*\)\=\%([eE][-+]\=\d\+\)\=\>"
syn match fennelNumber "\<-\=0[xX]\x\+\%(\.\x*\)\=\%([pP][-+]\=\d\+\)\=\>"

" ---------------------------------------------------------------- literals --
syn keyword fennelBoolean true false
syn keyword fennelConstant nil

" :keyword style strings
syn match fennelKeyword ":\@<!:[a-zA-Z_][a-zA-Z0-9_?!*<>=+/.$%&^~-]*"

" ------------------------------------------------------------ special forms --
syn keyword fennelSpecialForm
      \ fn lambda λ hashfn partial
      \ local var set global let
      \ if when do while for each match match-try case case-try
      \ and or not
      \ quote unquote
      \ tset values
      \ require-macros import-macros macro macros macrodebug eval-compiler include
      \ lua length
      \ pick-values pick-args
      \ doto with-open
      \ collect icollect accumulate fcollect faccumulate
      \ where
      \ comment

" -> ->> -?> -?>> as well as .. . ? # : operators
syn match fennelSpecialForm "\%(^\|[[({[:space:]]\)\@<=-\%(?\)\=>>\=\%([[:space:]()]\)\@="
syn match fennelOperator "\%(^\|[[({[:space:]]\)\@<=\%(\.\.\|\.\|#\|?\.\|\^\|[-+*/%<>]\|[<>=~!]=\|=\|//\)\%([[:space:]()]\)\@="

" --------------------------------------------------- commonly used builtins --
syn keyword fennelFunc
      \ print require pairs ipairs select type tostring tonumber
      \ setmetatable getmetatable rawget rawset rawequal rawlen
      \ pcall xpcall error assert unpack next load loadstring dofile
      \ math table string os io coroutine debug utf8

" ------------------------------------------------------- delimiter matching --
syn region fennelList   matchgroup=fennelParen start="(" end=")" contains=TOP,fennelTodo fold
syn region fennelVector matchgroup=fennelBracket start="\[" end="\]" contains=TOP,fennelTodo fold
syn region fennelTable  matchgroup=fennelBrace start="{" end="}" contains=TOP,fennelTodo fold
syn match  fennelError ")\|\]\|}"

" ------------------------------------------------------------- highlighting --
hi def link fennelComment       Comment
hi def link fennelTodo          Todo
hi def link fennelShebang       PreProc
hi def link fennelString        String
hi def link fennelStringEscape  SpecialChar
hi def link fennelNumber        Number
hi def link fennelBoolean       Boolean
hi def link fennelConstant      Constant
hi def link fennelKeyword       Identifier
hi def link fennelSpecialForm   Statement
hi def link fennelOperator      Operator
hi def link fennelFunc          Function
hi def link fennelParen         Delimiter
hi def link fennelBracket       Delimiter
hi def link fennelBrace         Delimiter
hi def link fennelError         Error

syn sync fromstart

let b:current_syntax = 'fennel'


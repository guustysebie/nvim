(fn hello [name]
  (print (.. "Hello, " (or name "world") "!")))

(fn something-else []
  (print "hello world"))

;; export every function you want available in neovim here
;; use underscore keys: each becomes a global and a :Command
{:hello hello
 :something_else something-else
}

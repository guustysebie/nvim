(local {: dump : format-as-line} (require :generated.print-util))

(fn hello [name]
  (print "Hello this and that frank de tank!!!")
)


(fn job-collect [cmd on-done cwd]
  "Buffered example: collect ALL output, then call (on-done code stdout stderr).
  With `stdout_buffered true` the callback fires once, at exit, with every line.
  Optionally pass `cwd` as the third argument to run the job in another directory."
  (var out [])
  (var err [])
  (let [job-opts {:stdout_buffered true
                  :stderr_buffered true
                  :on_stdout (fn [_ data _] (when data (set out data)))
                  :on_stderr (fn [_ data _] (when data (set err data)))
                  :on_exit (fn [_ code _]
                             ;; callbacks already run on the main loop, but wrap API calls in
                             ;; vim.schedule if you ever call this from a fast event context
                             (on-done code out err))}]
    (when cwd
      (tset job-opts :cwd cwd))
    (vim.fn.jobstart cmd job-opts)))


(fn fnl-compile-nvim [cont]
  (print "Compiling all source files using")
  (job-collect 
    ["bash" "-c" "/home/guust/.config/nvim/compile-all.sh"]  
    (fn [code out err] 
      (print (format-as-line out))
      (print "err:" )
      (print (format-as-line err))
      (cont)
      )
    "/home/guust/.config/nvim/"
    )
  )
(fn lua-reload-config []
  "Reload init.lua and report success/failure via notifications."
  (let [(ok err) (xpcall
                   (fn []
                     ;; force fresh load for this generated module before re-sourcing init
                     (tset package.loaded "generated.functions" nil)
                     (dofile vim.env.MYVIMRC))
                   debug.traceback)]
    (if ok
        (vim.notify "Lua config reloaded" vim.log.levels.INFO)
        (vim.notify (.. "Lua config reload failed:\n" err) vim.log.levels.ERROR))))

(fn lua-compile-fnl-and-reload []
    (fnl-compile-nvim lua-reload-config)
)

(fn test-format []
  ( local t ["hello" "second"])
  (print  (format-as-line t )))



;; export every function you want available in neovim here
;; use underscore keys: each becomes a global and a :Command
{
:Hello hello
:LuaCompileFnlAndReload lua-compile-fnl-and-reload
:TestFormat test-format
}

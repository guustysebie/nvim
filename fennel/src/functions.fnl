(local {: dump : format-as-line} (require :generated.print-util))


(fn _G.hello [name]
  (print (.. "hello " name)))


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
  (each [mod _ (pairs package.loaded)]
    (when (mod:match "^generated%.")
      (tset package.loaded mod nil)))
  (let [(ok err) (xpcall
                   (fn []
                     (dofile vim.env.MYVIMRC))
                   debug.traceback)]
    (if ok
        (vim.notify "Lua config reloaded" vim.log.levels.INFO)
        (vim.notify (.. "Lua config reload failed:\n" err) vim.log.levels.ERROR))))

(fn lua-compile-fnl-and-reload []
    (fnl-compile-nvim lua-reload-config)
)

(var fennel-repl-chan nil)

(fn fennel-repl-start []
  (vim.cmd.vnew)
  (vim.cmd.wincmd "J")
  (vim.api.nvim_win_set_height 0 12)
  (let [chan (vim.fn.termopen
               ["fennel"
                "--add-package-path" "./lua/?.lua"
                "--load" "./fennel/repl-init.fnl"
                "--repl"]
               {:cwd "/home/guust/.config/nvim"})]
    (if (> chan 0)
        (do
          (set fennel-repl-chan chan)
          (vim.cmd.startinsert)
          (vim.notify "Fennel REPL started. Use :FennelReplReload to run (reload!)." vim.log.levels.INFO))
        (vim.notify "Failed to start Fennel REPL" vim.log.levels.ERROR))))

(fn fennel-repl-reload []
  (if (not fennel-repl-chan)
      (vim.notify "No Fennel REPL channel. Start one with :FennelReplStart" vim.log.levels.WARN)
      (let [state (. (vim.fn.jobwait [fennel-repl-chan] 0) 1)]
        (if (= state -1)
            (do
              (vim.fn.chansend fennel-repl-chan "(reload!)\n")
              (vim.notify "Sent (reload!) to Fennel REPL" vim.log.levels.INFO))
            (do
              (set fennel-repl-chan nil)
              (vim.notify "Fennel REPL is not running. Start one with :FennelReplStart" vim.log.levels.WARN))))))

(fn test-format []
  ( local t ["hello" "second"])
  (print  (format-as-line t )))



;; export every function you want available in neovim here
;; use underscore keys: each becomes a global and a :Command
{
:Hello hello
:LuaCompileFnlAndReload lua-compile-fnl-and-reload
:FennelReplStart fennel-repl-start
:FennelReplReload fennel-repl-reload
:TestFormat test-format
}

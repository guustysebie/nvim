(fn hello-window []
  "Open a small centered floating window containing some text."
  (let [lines ["hello window there"]
        width (+ 4 (length (. lines 1)))
        height (length lines)
        ;; scratch buffer: unlisted + wiped when hidden
        buf (vim.api.nvim_create_buf false true)
        opts {:relative "editor"
              :width width
              :height height
              :row (math.floor (/ (- vim.o.lines height) 2))
              :col (math.floor (/ (- vim.o.columns width) 2))
              :style "minimal"
              :border "rounded"
              :title " popup "
              :title_pos "center"}]
    (vim.api.nvim_buf_set_lines buf 0 -1 false lines)
    (let [win (vim.api.nvim_open_win buf true opts)]
      ;; q or <Esc> closes the popup
      (each [_ key (ipairs ["q" "<Esc>"])]
        (vim.keymap.set :n key #(vim.api.nvim_win_close win true)
                        {:buffer buf :nowait true :silent true}))
      win)))

(fn hello-buffer []
  "Open a scratch buffer in a vertical split on the right side."
  (let [lines ["hello buffer there"]
        buf (vim.api.nvim_create_buf false true)
        win (vim.api.nvim_open_win buf true {:split "right" :win 0 :width 40})]
    (vim.api.nvim_buf_set_lines buf 0 -1 false lines)
    ;; make it behave like a throwaway side panel
    (vim.api.nvim_set_option_value :bufhidden :wipe {:buf buf})
    (vim.api.nvim_set_option_value :filetype :hellobuffer {:buf buf})
    (vim.api.nvim_set_option_value :number false {:win win})
    (vim.api.nvim_set_option_value :relativenumber false {:win win})
    (vim.keymap.set :n :q #(vim.api.nvim_win_close win true)
                    {:buffer buf :nowait true :silent true})
    win))

;; =========================== jobstart / async jobs ===========================
;; `vim.fn.jobstart` runs a program asynchronously and calls Lua callbacks as
;; output arrives. Signature: (vim.fn.jobstart cmd opts) -> job-id
;;   job-id > 0  the job handle
;;   job-id == 0 invalid arguments
;;   job-id == -1 the command is not executable
;; Pass `cmd` as a LIST to avoid shell quoting problems; pass a STRING only when
;; you deliberately want it run through 'shell'.

(fn strip-cr [s]
  ;; gsub returns 2 values; pick-values 1 keeps only the string
  (pick-values 1 (string.gsub s "\r$" "")))

(fn one-line [s]
  ;; nvim_buf_set_lines rejects strings containing newlines
  (pick-values 1 (string.gsub s "[\r\n]" " ")))

(fn dump [o]
  "Serialize nested Lua tables for quick debugging output."
  (if (= (type o) "table")
      (do
        (var s "{ ")
        (each [k v (pairs o)]
          (let [key (if (not= (type k) "number")
                        (.. "\"" k "\"")
                        k)]
            (set s (.. s "[" key "] = " (dump v) ","))))
        (.. s "} "))
      (tostring o)))

(fn dump-example []
  "Quick demo for `dump`: show a nested table in a notification."
  (let [sample {:project "nvim"
                :enabled true
                :numbers [1 2 3]
                :nested {:k "v" :depth 2}}
        text (dump sample)]
    (vim.notify text)
    text))

(fn scratch-split [title]
  "Helper: scratch buffer in a right split, used to display job output."
  (let [buf (vim.api.nvim_create_buf false true)
        win (vim.api.nvim_open_win buf true {:split "right" :win 0 :width 60})]
    (vim.api.nvim_set_option_value :bufhidden :wipe {:buf buf})
    (vim.api.nvim_buf_set_lines buf 0 -1 false [(one-line (.. "$ " title)) ""])
    (values buf win)))

(fn job-stream [...]
  "Streaming example: run a command and append its output live.
  Usage: (job-stream \"ls\" \"-la\") — defaults to `ls -la`."
  (let [cmd (if (> (select "#" ...) 0) [...] ["ls" "-la"])
        (buf _win) (scratch-split (table.concat cmd " "))
        append (fn [chunk]
                 ;; jobstart splits output on newlines; the LAST element is a
                 ;; partial line ("" when the chunk ended on a newline), so a
                 ;; real implementation should buffer it. Here we just drop
                 ;; empty strings.
                 (when (vim.api.nvim_buf_is_valid buf)
                   (let [lines (icollect [_ l (ipairs chunk)]
                                 (when (not= l "") (one-line (strip-cr l))))]
                     (when (> (length lines) 0)
                       (vim.api.nvim_buf_set_lines buf -1 -1 false lines)))))
        job (vim.fn.jobstart cmd
              {;; false = callbacks fire per chunk (streaming)
               :stdout_buffered false
               :stderr_buffered false
               ;; every callback receives (job-id data event-name)
               :on_stdout (fn [_ data _] (when data (append data)))
               :on_stderr (fn [_ data _] (when data (append data)))
               :on_exit (fn [_ code _]
                          (append [(.. "-- exited with code " code " --")]))
               ;; :cwd "/tmp"  ;; run somewhere else
               ;; :env {:FOO "bar"} ;; extra environment variables
               })]
    (when (<= job 0)
      (vim.notify (.. "jobstart failed for " (vim.inspect cmd)) vim.log.levels.ERROR))
    job))

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

(fn job-git-branch []
  "Practical use of job-collect: show the current git branch without blocking."
  (job-collect ["git" "rev-parse" "--abbrev-ref" "HEAD"]
               (fn [code out err]
                 (if (= code 0)
                     (vim.notify (.. "branch: " (or (. out 1) "?")))
                     (vim.notify (.. "git failed: " (table.concat err " "))
                                 vim.log.levels.WARN)))))

(fn job-stdin []
  "Writing to a job's stdin with chansend, and closing it with chanclose."
  (let [job (vim.fn.jobstart ["cat"]
              {:stdout_buffered true
               :on_stdout (fn [_ data _]
                            (when data
                              (vim.notify (.. "cat echoed: " (table.concat data "/")))))})]
    (when (> job 0)
      (vim.fn.chansend job ["line one" "line two" ""])
      ;; close stdin so `cat` sees EOF and exits
      (vim.fn.chanclose job :stdin)
      job)))

(fn job-terminal []
  "Run a command inside a real terminal buffer: `term` makes jobstart attach the
  job to the current buffer's pty (colors, TUI programs, etc.)."
  (vim.cmd.vnew)
  (vim.fn.jobstart ["ping" "-c" "3" "127.0.0.1"] {:term true})
  (vim.cmd.startinsert))

(fn job-wait-and-stop []
  "Blocking wait and cancellation.
  (vim.fn.jobwait [ids] timeout-ms) -> list of exit codes (-1 = timeout)
  (vim.fn.jobstop id) sends SIGTERM."
  (let [fast (vim.fn.jobstart ["true"])
        ;; NOTE: an empty lua table `{}` reaches vimscript as an empty LIST and
        ;; jobstart then errors with "expected dictionary" — either omit the
        ;; options argument entirely (as here) or use (vim.empty_dict)
        slow (vim.fn.jobstart ["sleep" "30"])
        results (vim.fn.jobwait [fast slow] 200)]
    (vim.fn.jobstop slow)
    ;; results -> [0 -1] : the first finished, the second timed out
    results))

;; Modern alternative (Neovim 0.10+): `vim.system` wraps all of the above and
;; can be used synchronously with :wait
;;   (let [res (: (vim.system ["git" "status"] {:text true}) :wait)]
;;     (print res.code res.stdout))
;; or asynchronously by passing a callback as the third argument.

{:hello_window hello-window
 :hello_buffer hello-buffer
 :dump dump
 :dump_example dump-example
 :job_stream job-stream
 :job_collect job-collect
 :job_git_branch job-git-branch
 :job_stdin job-stdin
 :job_terminal job-terminal
 :job_wait_and_stop job-wait-and-stop}


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

;; Bootstraps a REPL session from fennel/src by compiling and loading generated.* modules.

(local src-glob "./fennel/src/*.fnl")
(local compile-cmd "./compile-all.sh")

(fn list-modules []
  (let [handle (io.popen (.. "find ./fennel/src -maxdepth 1 -type f -name '*.fnl' -printf '%f\\n'"))]
    (if (not handle)
        []
        (let [mods []]
          (each [line (handle:lines)]
            (let [mod (line:gsub "%.fnl$" "")]
              (when (not= mod "")
                (table.insert mods mod))))
          (handle:close)
          (table.sort mods)
          mods))))

(var loaded-modules {})

(fn load-generated! [mods]
  (set loaded-modules {})
  (each [_ mod (ipairs mods)]
    (let [generated-name (.. "generated." mod)]
      (tset package.loaded generated-name nil)
      (let [(ok result) (pcall require generated-name)]
        (if ok
            (do
              (tset loaded-modules mod result)
              (print (.. "loaded " generated-name)))
            (print (.. "failed " generated-name ": " (tostring result))))))))

(fn reload! []
  (os.execute compile-cmd)
  (load-generated! (list-modules))
  loaded-modules)

(fn getmod [name]
  (. loaded-modules name))

(tset _G :reload! reload!)
(tset _G :getmod getmod)

(print (.. "Fennel REPL bootstrap scanning " src-glob " -> generated.*"))
(reload!)
(print "Ready. Run (reload!) to recompile + reload all fennel/src modules.")
(print "Use (getmod \"functions\") to inspect a loaded module table.")






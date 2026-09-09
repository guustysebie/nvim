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

(fn format-as-line [o]
  "Formats all strings as a single thing"
  (if (= (type o) "table")
    (do
      (var s "")
      (each [k v (pairs o)]
        (set s (.. s v "\n")))
      s)
    (tostring o)))

{
    :format-as-line format-as-line
    :dump dump
}

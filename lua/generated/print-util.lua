local function dump(o)
  if (type(o) == "table") then
    local s = "{ "
    for k, v in pairs(o) do
      local key
      if (type(k) ~= "number") then
        key = ("\"" .. k .. "\"")
      else
        key = k
      end
      s = (s .. "[" .. key .. "] = " .. dump(v) .. ",")
    end
    return (s .. "} ")
  else
    return tostring(o)
  end
end
local function format_as_line(o)
  if (type(o) == "table") then
    local s = ""
    for k, v in pairs(o) do
      s = (s .. v .. "\n")
    end
    return s
  else
    return tostring(o)
  end
end
return {["format-as-line"] = format_as_line, dump = dump}

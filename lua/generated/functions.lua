local _local_1_ = require("generated.print-util")
local dump = _local_1_["dump"]
local format_as_line = _local_1_["format-as-line"]
local function hello(name)
  return print("Hello this and that frank de tank!!!")
end
local function job_collect(cmd, on_done, cwd)
  local out = {}
  local err = {}
  local job_opts
  local function _2_(_, data, _0)
    if data then
      out = data
      return nil
    else
      return nil
    end
  end
  local function _4_(_, data, _0)
    if data then
      err = data
      return nil
    else
      return nil
    end
  end
  local function _6_(_, code, _0)
    return on_done(code, out, err)
  end
  job_opts = {stdout_buffered = true, stderr_buffered = true, on_stdout = _2_, on_stderr = _4_, on_exit = _6_}
  if cwd then
    job_opts["cwd"] = cwd
  else
  end
  return vim.fn.jobstart(cmd, job_opts)
end
local function fnl_compile_nvim(cont)
  print("Compiling all source files using")
  local function _8_(code, out, err)
    print(format_as_line(out))
    print("err:")
    print(format_as_line(err))
    return cont()
  end
  return job_collect({"bash", "-c", "/home/guust/.config/nvim/compile-all.sh"}, _8_, "/home/guust/.config/nvim/")
end
local function lua_reload_config()
  for mod, _ in pairs(package.loaded) do
    if mod:match("^generated%.") then
      package.loaded[mod] = nil
    else
    end
  end
  local ok, err = nil, nil
  local function _10_()
    return dofile(vim.env.MYVIMRC)
  end
  ok, err = xpcall(_10_, debug.traceback)
  if ok then
    return vim.notify("Lua config reloaded", vim.log.levels.INFO)
  else
    return vim.notify(("Lua config reload failed:\n" .. err), vim.log.levels.ERROR)
  end
end
local function lua_compile_fnl_and_reload()
  return fnl_compile_nvim(lua_reload_config)
end
local function test_format()
  local t = {"hello", "second"}
  return print(format_as_line(t))
end
return {Hello = hello, LuaCompileFnlAndReload = lua_compile_fnl_and_reload, TestFormat = test_format}

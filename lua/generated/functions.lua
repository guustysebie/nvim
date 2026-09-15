local _local_1_ = require("generated.print-util")
local dump = _local_1_["dump"]
local format_as_line = _local_1_["format-as-line"]
_G.hello = function(name)
  return print(("hello " .. name))
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
local fennel_repl_chan = nil
local function fennel_repl_start()
  vim.cmd.vnew()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 12)
  local chan = vim.fn.termopen({"fennel", "--add-package-path", "./lua/?.lua", "--load", "./fennel/repl-init.fnl", "--repl"}, {cwd = "/home/guust/.config/nvim"})
  if (chan > 0) then
    fennel_repl_chan = chan
    vim.cmd.startinsert()
    return vim.notify("Fennel REPL started. Use :FennelReplReload to run (reload!).", vim.log.levels.INFO)
  else
    return vim.notify("Failed to start Fennel REPL", vim.log.levels.ERROR)
  end
end
local function fennel_repl_reload()
  if not fennel_repl_chan then
    return vim.notify("No Fennel REPL channel. Start one with :FennelReplStart", vim.log.levels.WARN)
  else
    local state = vim.fn.jobwait({fennel_repl_chan}, 0)[1]
    if (state == -1) then
      vim.fn.chansend(fennel_repl_chan, "(reload!)\n")
      return vim.notify("Sent (reload!) to Fennel REPL", vim.log.levels.INFO)
    else
      fennel_repl_chan = nil
      return vim.notify("Fennel REPL is not running. Start one with :FennelReplStart", vim.log.levels.WARN)
    end
  end
end
local function test_format()
  local t = {"hello", "second"}
  return print(format_as_line(t))
end
return {Hello = hello, LuaCompileFnlAndReload = lua_compile_fnl_and_reload, FennelReplStart = fennel_repl_start, FennelReplReload = fennel_repl_reload, TestFormat = test_format}

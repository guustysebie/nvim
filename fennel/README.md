# Fennel REPL quick use

Commands (from Neovim):

- `:LuaCompileFnlAndReload` - compile `fennel/src/*.fnl` to `lua/generated/*.lua`, then reload config.
- `:FennelReplStart` - open a bottom terminal and start a Fennel REPL with your generated modules preloaded.
- `:FennelReplReload` - send `(reload!)` to that REPL (recompiles + reloads all modules from `fennel/src`).

Inside REPL:

- `(reload!)` - same as `:FennelReplReload`.
- `(getmod "functions")` - get a loaded module table (replace `functions` with any module name from `fennel/src`).


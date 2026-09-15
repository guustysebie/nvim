--choco install fdpre requisites
--https://github.com/sharkdp/fd
--ripgrep
-- on windows choco install mingw on linux just need a c compiler and make I suppose

-- Basic Settings
vim.opt.compatible = false             -- Disable compatibility to old-time vi
vim.opt.showmatch = true               -- Show matching brackets
vim.opt.ignorecase = true              -- Case insensitive search
vim.opt.mouse = "a"                    -- Enable mouse support
vim.opt.hlsearch = true                -- Highlight search results
vim.opt.incsearch = true               -- Incremental search
vim.opt.tabstop = 4                    -- Number of columns occupied by a tab
vim.opt.softtabstop = 4                -- Number of spaces in tab when editing
vim.opt.expandtab = true               -- Convert tabs to spaces
vim.opt.shiftwidth = 4                 -- Width for autoindents
vim.opt.autoindent = true              -- Auto indent new lines
vim.opt.number = true                  -- Show line numbers
vim.opt.wildmode = {"longest", "list"} -- Bash-like tab completions
vim.opt.colorcolumn = "120"             -- Set an 80 column border
vim.opt.signcolumn = "yes"             -- allow space for thing
--vim.opt.cursorline = true              -- Highlight current line
vim.opt.ttyfast = true                 -- Speed up scrolling
vim.opt.clipboard = "unnamedplus"      -- Use system clipboard
vim.opt.wrap = false

-- Syntax Highlighting and Filetype Detection
vim.cmd("filetype plugin indent on")   -- Enable file type detection and plugins
vim.cmd("syntax on")                   -- Enable syntax highlighting

-- Optional Settings (Uncomment if needed)
-- vim.opt.spell = true                  -- Enable spell check
vim.opt.swapfile = false              -- Disable creating swap files
vim.opt.backupdir = vim.fn.expand("~/.cache/vim") -- Directory for backup files

--opens vsp to the right 
vim.opt.splitright = true
vim.opt.clipboard = "unnamedplus"

vim.g.have_nerd_font = false

-- Make line numbers default
vim.opt.relativenumber = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true


vim.keymap.set('n', 'q', ':q!<CR>', { noremap = true, silent = true })
-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }



-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.cmd [[colorscheme default]]

-- REMAPS --
vim.g.mapleader = ","
-- open netrw 
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)



-- Telescope config this is the thing for fuzzy finding
local status, telescope_builtin = pcall(require, 'telescope.builtin')
if status then
    -- Module is available, use it
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
    require('telescope').setup{
        pickers = {
            find_files = {
                theme="ivy"
            },
            live_grep = {
                theme="ivy"
            }
        }
    }
else
    -- Module is not installed, handle it gracefully
    print("Telescope is not installed")
end

--if  package.loaded['telescope.builtin'] then
--end

-- ============================== TERMINAL CONFIG =============================
-- exit terminal
vim.api.nvim_set_keymap('t', '<leader>te', [[<C-\><C-n>]], { noremap = true, silent = true })
vim.api.nvim_create_autocmd('TermOpen', {
    group = vim.api.nvim_create_augroup('custom-rem-open',{clear =true}),
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
    end
})
-- open a small terminal
vim.keymap.set("n", "<leader>ts", function() 
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0,10)
end)
-- ============================== Execute lua =============================
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>")
vim.keymap.set("n", "<leader>x", ":.lua<CR>")
vim.keymap.set("v", "<leader>x", ":lua<CR>")

-- custom listener to highlight text on yanking
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', {clear = true}),
    callback = function()
        vim.highlight.on_yank()
    end
})



-- Automatically check if files changed when gaining focus or entering a buffer
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  pattern = "*",
  command = "silent! checktime",
})



-- ===============================iText shortcuts=============
-- :ReplacePdfFiles / :ReplacePdfFilesAndQuit / <leader>rpd -> lua/itext-replace-pdf.lua
-- :OpenCmp                                                 -> lua/itext-open-cmp.lua
require('itext-replace-pdf')
require('itext-open-cmp')

-- =============================== Fennel generated functions =============
-- Every function exported from lua/generated/*.lua becomes:
--   * a global   -> :lua hello("guust") / :lua hello_window()
--   * a command  -> :Hello guust       / :HelloWindow
-- (command names may only contain letters/digits, so foo_bar -> FooBar)
local function to_command_name(name)
    return (name:gsub('(%a)([%w]*)_?', function(first, rest)
        return first:upper() .. rest
    end))
end


local generated_dir = vim.fn.stdpath('config') .. '/lua/generated'
for _, file in ipairs(vim.fn.glob(generated_dir .. '/*.lua', false, true)) do
    local modname = vim.fn.fnamemodify(file, ':t:r')
    local ok, mod = pcall(require, 'generated.' .. modname)
    if not ok then
        vim.notify('failed to load generated.' .. modname .. ': ' .. tostring(mod), vim.log.levels.WARN)
    elseif type(mod) == 'table' then
        for name, fn in pairs(mod) do
            if type(fn) == 'function' then
                if string.match(name, "^%u") then
                    _G[name] = fn
                    local cmd_ok, err = pcall(vim.api.nvim_create_user_command, to_command_name(name), function(o)
                        fn(unpack(o.fargs))
                    end, { nargs = '*' })
                    if not cmd_ok then
                        vim.notify('could not create command for ' .. name .. ': ' .. tostring(err), vim.log.levels.WARN)
                    end
                else 
                end
            end
        end
    end
end

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
-- ===============================iText shortcuts=============
local function replace_pdf_files()
    -- Get the current buffer content
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local pdf_pairs = {}

    -- Find all Out pdf and Cmp pdf paths
    for i, line in ipairs(lines) do
        local out_match = line:match("^Out pdf:%s*file://(.+)$")
        local cmp_match = line:match("^Cmp pdf:%s*file://(.+)$")
        
        if out_match then
            -- Look ahead to find the next Cmp pdf
            for j = i + 1, #lines do
                local next_cmp_match = lines[j]:match("^Cmp pdf:%s*file://(.+)$")
                if next_cmp_match then
                    table.insert(pdf_pairs, {out = out_match, cmp = next_cmp_match})
                    break
                end
            end
        end
    end

    -- Check if any PDF pairs were found
    if #pdf_pairs == 0 then
        print("No PDF replacement pairs found")
        return
    end

    -- Track successful and failed replacements
    local successful_replacements = 0
    local failed_replacements = 0

    -- Replace each PDF pair
    for _, pair in ipairs(pdf_pairs) do
        -- Use vim.fn.system for file operations
        local copy_cmd = string.format("cp %s %s", pair.out, pair.cmp)
        local result = vim.fn.system(copy_cmd)
        
        -- Check for errors
        if vim.v.shell_error ~= 0 then
            print(string.format("Error replacing %s with %s: %s", pair.cmp, pair.out, result))
            failed_replacements = failed_replacements + 1
        else
            successful_replacements = successful_replacements + 1
        end
    end

    -- Provide summary
    print(string.format("PDF Replacement Summary: %d successful, %d failed", 
        successful_replacements, failed_replacements))
end

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    if vim.bo.filetype == "" then
      vim.cmd("AnsiEsc")
    end
  end,
})



-- Create a user command to call the function
vim.api.nvim_create_user_command('ReplacePdfFiles', replace_pdf_files, {})

require("itext-pr-urls")


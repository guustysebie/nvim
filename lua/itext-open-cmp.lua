-- Open the urls/pdfs described by the current visual selection in firefox.
--
-- Expected (selected) pattern, the "Github url" line is optional:
--
--   Github url: https://github.com/anthropics/skills
--   Out pdf: file:///path/to/out/README.pdf
--   Cmp pdf: file:///path/to/cmp/cmp_README.pdf
--
-- Exposes the :OpenCmp command (works on a range, e.g. from visual mode).

local M = {}

local BROWSER = 'firefox'

--- Return the lines of the last/current visual selection.
local function visual_selection_lines()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_line, end_line = start_pos[2], end_pos[2]

    if start_line == 0 or end_line == 0 then
        return {}
    end

    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end

    return vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
end

--- Parse lines and return the matched urls, or nil when the pattern does not match.
--- @param lines string[]
--- @return string[]|nil urls, string|nil err
function M.parse(lines)
    local github, out_pdf, cmp_pdf

    for _, line in ipairs(lines) do
        line = vim.trim(line)
        github = github or line:match("^Github url:%s*(%S+)%s*$")
        out_pdf = out_pdf or line:match("^Out pdf:%s*(%S+)%s*$")
        cmp_pdf = cmp_pdf or line:match("^Cmp pdf:%s*(%S+)%s*$")
    end

    if not out_pdf then
        return nil, "no 'Out pdf:' line found in the selection"
    end
    if not cmp_pdf then
        return nil, "no 'Cmp pdf:' line found in the selection"
    end

    local urls = {}
    if github then
        table.insert(urls, github)
    end
    table.insert(urls, out_pdf)
    table.insert(urls, cmp_pdf)

    return urls
end

--- Open the given urls as new tabs in firefox (reuses a running instance).
local function open_in_browser(urls)
    if vim.fn.executable(BROWSER) == 0 then
        vim.notify(BROWSER .. ' is not installed / not on $PATH', vim.log.levels.ERROR)
        return
    end

    for _, url in ipairs(urls) do
        -- --new-tab reuses an already running firefox instance when there is one,
        -- otherwise firefox simply starts up and opens the url.
        vim.fn.jobstart({ BROWSER, '--new-tab', url }, { detach = true })
    end

    vim.notify('opened ' .. #urls .. ' tab(s) in ' .. BROWSER)
end

--- Check the selection (or the given lines) and open everything in firefox.
--- @param lines string[]|nil defaults to the current visual selection
function M.open_cmp(lines)
    lines = lines or visual_selection_lines()

    if vim.tbl_isempty(lines) then
        vim.notify('no selection found', vim.log.levels.WARN)
        return
    end

    local urls, err = M.parse(lines)
    if not urls then
        vim.notify('selection does not match the expected pattern: ' .. err, vim.log.levels.WARN)
        return
    end

    open_in_browser(urls)
end

vim.api.nvim_create_user_command('OpenCmp', function(opts)
    local lines
    if opts.range > 0 then
        lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
    end
    M.open_cmp(lines)
end, { range = true, desc = 'Open the Github url / Out pdf / Cmp pdf of the selection in firefox' })

return M


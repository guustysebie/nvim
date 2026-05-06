local libgy = {}

function libgy.start_process(value)
    -- Open the URL in the default browser (works for Linux, macOS, and Windows)
    local open_cmd
    if vim.fn.has("mac") == 1 then
        open_cmd = "open " .. value
    elseif vim.fn.has("unix") == 1 then
        open_cmd = "xdg-open " .. value
    elseif vim.fn.has("win32") == 1 then
        open_cmd = "start " .. value
    else
        print("Unsupported OS")
        return
    end
    os.execute(open_cmd)
end


local function exec_command(cmd)
    -- execute the function and get all contents
    local output = vim.system(cmd,  { text = true }):wait() -- Runs the command and captures stdout
    if output == nil then
        return ""
    end
    local stdout = output.stdout
    if stdout == nil then
        return ""
    end
    return (string.gsub(stdout,  "^%s*(.-)%s*$", "%1"))
end

function libgy.get_branch_name()
    print(exec_command({
        "git" :  'rev-parse --abbrev-ref HEAD'}
        ))
end
return libgy;

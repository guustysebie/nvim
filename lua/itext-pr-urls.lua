local function is_git_repo(path)
  local git_path = path .. "/.git"
  return vim.fn.isdirectory(git_path) == 1 or vim.fn.filereadable(git_path) == 1
end

local function process_repo(repo_path, name, branch, results)
  -- check if branch exists on remote
  local check_cmd = string.format(
    "git -C %s ls-remote --heads origin %s",
    vim.fn.shellescape(repo_path),
    vim.fn.shellescape(branch)
  )
  local remote_out = vim.fn.system(check_cmd)

  if vim.v.shell_error == 0 and remote_out:gsub("%s+", "") ~= "" then
    -- branch exists remotely, fetch PR url via gh
    local pr_cmd = string.format(
      "cd %s && gh pr view %s --json url -q .url 2>/dev/null",
      vim.fn.shellescape(repo_path),
      vim.fn.shellescape(branch)
    )
    local pr_url = vim.fn.system(pr_cmd):gsub("%s+$", "")

    if vim.v.shell_error == 0 and pr_url ~= "" then
      table.insert(results, name .. ": " .. pr_url)
    else
      table.insert(results, name .. ": (no PR found for branch)")
    end
  end
end

local function scan_dir(dir, branch, results, depth, max_depth, rel_prefix)
  local handle = vim.loop.fs_scandir(dir)
  if not handle then return end

  while true do
    local name, ftype = vim.loop.fs_scandir_next(handle)
    if not name then break end

    if ftype == "directory" and name ~= ".git" then
      local full_path = dir .. "/" .. name
      local rel_name = rel_prefix and (rel_prefix .. "/" .. name) or name

      if is_git_repo(full_path) then
        process_repo(full_path, rel_name, branch, results)
        -- don't recurse further into a repo's own subfolders
      elseif depth < max_depth then
        scan_dir(full_path, branch, results, depth + 1, max_depth, rel_name)
      end
    end
  end
end

local function get_pr_urls_for_branch(source_dir, branch, max_depth)
  max_depth = max_depth or 3
  local results = {}

  if vim.fn.isdirectory(source_dir) ~= 1 then
    vim.notify("Not a directory: " .. source_dir, vim.log.levels.ERROR)
    return
  end

  scan_dir(source_dir, branch, results, 1, max_depth, nil)

  table.sort(results)

  if #results == 0 then
    results = { "No matching repositories/branches found under " .. source_dir }
  end

  -- open results in a new scratch buffer
  vim.cmd("new")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, results)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  pcall(vim.api.nvim_buf_set_name, buf, "PR URLs: " .. branch)
end

vim.api.nvim_create_user_command("PrUrls", function(opts)
  local args = vim.split(opts.args, "%s+")
  local source_dir = args[1]
  local branch = args[2]
  local max_depth = tonumber(args[3]) or 3

  if not source_dir or not branch then
    vim.notify("Usage: :PrUrls <source_dir> <branch> [max_depth]", vim.log.levels.ERROR)
    return
  end

  get_pr_urls_for_branch(source_dir, branch, max_depth)
end, { nargs = "*" })

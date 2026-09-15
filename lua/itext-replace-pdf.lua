-- Replace cmp pdfs with the generated (out) pdfs listed in the current buffer.
-- Exposes the :ReplacePdfFiles command.

local M = {}

function M.replace_pdf_files()
    -- Get the current buffer content
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local pdf_pairs = {}

    -- Find all Out pdf and Cmp pdf paths
    for i, line in ipairs(lines) do
        local out_match = line:match("^Out pdf:%s*file://(.+)$")

        if out_match then
            -- Look ahead to find the next Cmp pdf
            for j = i + 1, #lines do
                local next_cmp_match = lines[j]:match("^Cmp pdf:%s*file://(.+)$")
                if next_cmp_match then
                    table.insert(pdf_pairs, { out = out_match, cmp = next_cmp_match })
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
        local result = vim.fn.system({ "cp", pair.out, pair.cmp })

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

--- Replace the pdfs and then quit neovim.
function M.replace_pdf_files_and_quit()
    M.replace_pdf_files()
    vim.cmd('qa!')
end

vim.api.nvim_create_user_command('ReplacePdfFiles', M.replace_pdf_files, {})
vim.api.nvim_create_user_command('ReplacePdfFilesAndQuit', M.replace_pdf_files_and_quit, {})
vim.api.nvim_create_user_command('Rpd', M.replace_pdf_files_and_quit, {})

return M


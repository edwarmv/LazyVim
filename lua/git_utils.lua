local M = {}

M.change_base = function(buffer, global)
  local root = LazyVim.root({ buf = buffer, normalize = true })

  local result = vim
    .system({ "git", "rev-parse", "--symbolic", "--branches", "--tags", "--remotes" }, { cwd = root })
    :wait()

  if result.code ~= 0 then
    vim.notify("Git command failed: " .. result.stderr, vim.log.levels.ERROR)
    return
  end

  local all = vim.split(result.stdout, "\n", { trimempty = true })
  local original_base = "Original base"
  table.insert(all, 1, original_base)

  vim.ui.select(all, { prompt = "Select branch" }, function(choice)
    if choice == nil then
      return
    elseif choice == original_base then
      choice = nil
    end
    require("gitsigns").change_base(choice, global)
  end)
end

return M

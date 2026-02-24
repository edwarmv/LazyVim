local M = {}

-- REF: https://github.com/AstroNvim/AstroNvim/blob/6d5750bb4fbefeb816bf6d9d088df72dfefb9724/lua/plugins/neo-tree.lua#L73-L105
M.copy_path = function(_filename, _filepath)
  local filename = _filename or vim.fn.expand("%:t")
  local filepath = _filepath or vim.fn.expand("%:p")

  local modify = vim.fn.fnamemodify

  local vals = {
    ["BASENAME"] = modify(filename, ":r"),
    ["EXTENSION"] = modify(filename, ":e"),
    ["FILENAME"] = filename,
    ["PATH (CWD)"] = modify(filepath, ":."),
    ["PATH (HOME)"] = modify(filepath, ":~"),
    ["PATH"] = filepath,
    ["URI"] = vim.uri_from_fname(filepath),
  }

  local options = vim.tbl_filter(function(val)
    return vals[val] ~= ""
  end, vim.tbl_keys(vals))
  if vim.tbl_isempty(options) then
    vim.notify("No values to copy", vim.log.levels.WARN)
    return
  end
  table.sort(options)
  vim.ui.select(options, {
    prompt = "Choose to copy to clipboard:",
    format_item = function(item)
      return ("%s: %s"):format(item, vals[item])
    end,
  }, function(choice)
    local result = vals[choice]
    if result then
      vim.notify(("Copied: `%s`"):format(result))
      vim.fn.setreg("+", result)
    end
  end)
end

return M

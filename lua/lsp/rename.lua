local M = {}

function M.lsp_buf_rename()
  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  -- Save cursor position explicitly
  local cursor = vim.api.nvim_win_get_cursor(win)

  local current_name = vim.fn.expand("<cword>")

  vim.ui.input({
    prompt = "New name: ",
    default = current_name,
  }, function(new_name)
    if not new_name or new_name == "" or new_name == current_name then
      return
    end

    -- Restore cursor position BEFORE rename
    vim.api.nvim_win_set_cursor(win, cursor)

    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    local rename_clients = {}

    for _, c in ipairs(clients) do
      if c.supports_method("textDocument/rename") then
        table.insert(rename_clients, c)
      end
    end

    if #rename_clients == 0 then
      vim.notify("No LSP clients support rename", vim.log.levels.WARN)
      return
    end

    if #rename_clients == 1 then
      vim.lsp.buf.rename(new_name)
      return
    end

    vim.ui.select(rename_clients, {
      prompt = "Select LSP to rename with:",
      format_item = function(c)
        return c.name
      end,
    }, function(client)
      if not client then
        return
      end

      -- Restore again, just to be safe
      vim.api.nvim_win_set_cursor(win, cursor)

      vim.lsp.buf.rename(new_name, {
        filter = function(c)
          return c.name == client.name
        end,
      })
    end)
  end)
end

return M

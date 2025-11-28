local M = {}

function M.lsp_buf_rename()
  -- Pre-fill with the word under cursor
  local current_name = vim.fn.expand("<cword>")

  vim.ui.input({
    prompt = "New name: ",
    default = current_name,
  }, function(new_name)
    if not new_name or new_name == "" or new_name == current_name then
      return
    end

    -- Get clients attached to the buffer
    local clients = vim.lsp.get_clients({ bufnr = 0 })
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

    -- Multiple clients → select one
    vim.ui.select(rename_clients, {
      prompt = "Select LSP to rename with:",
      format_item = function(c)
        return c.name
      end,
    }, function(client)
      if not client then
        return
      end

      vim.lsp.buf.rename(new_name, {
        filter = function(c)
          return c.id == client.id
        end,
      })
    end)
  end)
end

return M

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("TabLeave", {
  command = "let g:lasttab = tabpagenr()",
})

local pull_diagnostic_refresh = {}
local lsp_capability = require("vim.lsp._capability")

local function in_insert_mode()
  return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
end

local function pull_diag_update_in_insert_enabled()
  return vim.diagnostic.config().update_in_insert == true
end

local function refresh_pending_pull_diagnostics(client_id)
  if in_insert_mode() and not pull_diag_update_in_insert_enabled() then
    return
  end

  local client = vim.lsp.get_client_by_id(client_id)
  if not client then
    return
  end

  for bufnr in pairs(client.attached_buffers) do
    local diagnostics = lsp_capability.all.diagnostics
    local provider = diagnostics and diagnostics.active[bufnr]
    if provider and provider.client_state[client_id] then
      provider:refresh(client_id, false)
    end
  end
end

local pull_diag_group = vim.api.nvim_create_augroup("PullDiagnosticsRefresh", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = pull_diag_group,
  callback = function(ev)
    local client_id = ev.data.client_id
    local client = vim.lsp.get_client_by_id(client_id)
    if not client or not client:supports_method("textDocument/diagnostic") then
      return
    end

    vim.list_extend(pull_diagnostic_refresh, { client_id })
    refresh_pending_pull_diagnostics(client_id)
  end,
})

vim.api.nvim_create_autocmd({
  "TextChanged",
  "InsertLeave",
}, {
  group = pull_diag_group,
  callback = function()
    vim.iter(pull_diagnostic_refresh):each(function(client_id)
      refresh_pending_pull_diagnostics(client_id)
    end)
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  group = pull_diag_group,
  callback = function(ev)
    for idx, client_id in pairs(pull_diagnostic_refresh) do
      if client_id == ev.data.client_id then
        table.remove(pull_diagnostic_refresh, idx)
        break
      end
    end
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  callback = function(ev)
    -- fixes an error where the document color provider is not properly
    -- disabled when the LSP client is detached, which can lead to errors when
    -- the client is restarted.
    vim.lsp.document_color.enable(false, { client_id = ev.data.client_id })
  end,
})

-- When a tab is closed, switch to the tab on the left if it exists.
vim.api.nvim_create_autocmd("TabClosed", {
  callback = function(ev)
    local current_tab = tonumber(ev.file)
    local tab_on_left = current_tab - 1

    if tab_on_left >= 1 then
      vim.cmd.tabnext(tab_on_left)
    end
  end,
})

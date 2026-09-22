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

-- Neovim's built-in pull diagnostics are not as responsive as some LSP
-- clients, so request an update for the buffers that matter to the user.
-- This intentionally uses a private master API; fail loudly if its contract
-- changes instead of silently disabling the workaround.
require("vim.lsp.diagnostic")
local lsp_capability = require("vim.lsp._capability")
local diagnostics =
  assert(lsp_capability.all and lsp_capability.all.diagnostics, "Neovim pull-diagnostics capability is unavailable")
local pending_refreshes = {}
local refresh_delay = 150

local function update_in_insert()
  return vim.diagnostic.config().update_in_insert == true
end

local function schedule_refresh(client_id, bufnr)
  if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" and not update_in_insert() then
    return
  end

  pending_refreshes[client_id] = pending_refreshes[client_id] or {}
  local pending = pending_refreshes[client_id]
  pending[bufnr] = (pending[bufnr] or 0) + 1
  local request = pending[bufnr]

  vim.defer_fn(function()
    if pending[bufnr] ~= request then
      return
    end
    pending[bufnr] = nil

    if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" and not update_in_insert() then
      return
    end

    local client = vim.lsp.get_client_by_id(client_id)
    if not client then
      return
    end

    -- The provider can disappear while the deferred callback is waiting (for
    -- example, when a client detaches or a buffer is unloaded). That is a
    -- normal lifecycle race, not a configuration error.
    local provider = diagnostics.active[bufnr]
    if not provider or not provider.client_state[client_id] then
      return
    end
    provider:refresh(client_id)
  end, refresh_delay)
end

local function schedule_buffer_refresh(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/diagnostic" })
  vim.iter(clients):each(function(client)
    schedule_refresh(client.id, bufnr)
  end)
end

local function schedule_visible_refresh()
  local buffers = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local bufnr = vim.api.nvim_win_get_buf(win)
    if not buffers[bufnr] then
      buffers[bufnr] = true
      schedule_buffer_refresh(bufnr)
    end
  end
end

local pull_diag_group = vim.api.nvim_create_augroup("PullDiagnosticsRefresh", { clear = true })

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP" }, {
  group = pull_diag_group,
  callback = function(ev)
    if ev.event ~= "TextChanged" and not update_in_insert() then
      return
    end
    schedule_visible_refresh()
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  group = pull_diag_group,
  callback = schedule_visible_refresh,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = pull_diag_group,
  callback = schedule_visible_refresh,
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

vim.api.nvim_create_autocmd("InsertEnter", {
  desc = "Disable lsp.inlay_hint when in insert mode",
  callback = function(args)
    local filter = { bufnr = args.buf }
    local inlay_hint = vim.lsp.inlay_hint
    if inlay_hint.is_enabled(filter) then
      inlay_hint.enable(false, filter)
      vim.api.nvim_create_autocmd("InsertLeave", {
        once = true,
        desc = "Re-enable lsp.inlay_hint when leaving insert mode",
        callback = function()
          inlay_hint.enable(true, filter)
        end,
      })
    end
  end,
})

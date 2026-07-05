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

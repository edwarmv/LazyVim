-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "<c-b>", "<left>")
vim.keymap.set("i", "<c-f>", "<right>")
vim.keymap.set("c", "<c-a>", "<c-b>")
vim.keymap.set("i", "<c-l>", "<c-f>")
vim.keymap.set("c", "<c-b>", "<left>")
vim.keymap.set("c", "<c-f>", "<right>")
vim.keymap.set("n", "<c-w><c-l>", "<c-l><cmd>nohl<cr><cmd>lua Snacks.notifier.hide()<cr>")
-- toggle options
Snacks.toggle.option("scrollbind", { name = "Scrollbind" }):map("<leader><leader>us")

-- floating terminal
-- vim.keymap.set({ "n", "t" }, "<c-`>", function()
--   Snacks.terminal()
-- end, { desc = "Terminal (cwd)" })

-- save file
vim.keymap.set({ "i", "x", "n", "s" }, "<c-s-s>", "<cmd>wa<cr><esc>", { desc = "Save All Files" })

vim.keymap.set("n", "<leader>y", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  require("copy_path").copy_path()
end, { desc = "Yank path to clipboard" })

vim.keymap.set("n", "<leader><tab>m", function()
  vim.ui.input({ prompt = "Enter The Tab Index: " }, function(tab_index)
    if tab_index ~= nil then
      vim.cmd("tabmove" .. tab_index)
    end
  end)
end, { desc = "Move Tab" })

vim.keymap.set("n", "<leader><tab>O", function()
  vim.cmd("tabonly")
  vim.cmd("only")
  Snacks.bufdelete.other()
end, { desc = "Close Other Tabs And Buffers" })

vim.keymap.set("n", "<leader><tab><tab>", ":exe 'tabn '.g:lasttab<cr>", { silent = true, desc = "Last Used Tab" })

vim.keymap.set("n", "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })

vim.keymap.set("n", "<leader><tab>D", function()
  local tabnr = vim.api.nvim_get_current_tabpage()
  local wins = vim.api.nvim_tabpage_list_wins(tabnr)
  local bufs = {}
  local bufs_set = {}
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    if not bufs_set[buf] then
      table.insert(bufs, buf)
      bufs_set[buf] = true
    end
  end
  for _, buf in ipairs(bufs) do
    Snacks.bufdelete(buf)
  end
  vim.cmd("tabclose")
end, { desc = "Close Tab And Its Buffers" })

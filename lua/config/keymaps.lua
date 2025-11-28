-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "<c-b>", "<left>")
vim.keymap.set("i", "<c-f>", "<right>")
vim.keymap.set("c", "<c-a>", "<c-b>")
vim.keymap.set("c", "<c-l>", "<c-f>")
vim.keymap.set("c", "<c-b>", "<left>")
vim.keymap.set("c", "<c-f>", "<right>")
vim.keymap.set("n", "<c-w><c-l>", "<c-l><cmd>nohl<cr><cmd>lua Snacks.notifier.hide()<cr>")
-- toggle options
Snacks.toggle.option("scrollbind", { name = "Scrollbind" }):map("<localleader>us")

-- floating terminal
-- vim.keymap.set({ "n", "t" }, "<c-`>", function()
--   Snacks.terminal()
-- end, { desc = "Terminal (cwd)" })

-- save file
vim.keymap.del({ "i", "x", "n", "s" }, "<C-s>")
vim.keymap.set({ "i", "x", "n", "s" }, "<M-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
vim.keymap.set({ "i", "x", "n", "s" }, "<M-S>", "<cmd>wa<cr><esc>", { desc = "Save All Files" })

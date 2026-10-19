-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_blink_main = true
vim.g.lazyvim_ts_lsp = "tsc"
vim.g.snacks_animate = false
vim.g.trouble_lualine = false

local user_preferences = require("user_preferences")

local o = vim.o
o.winborder = "rounded"
o.timeoutlen = 500
o.cmdheight = 0
o.pumblend = 0
o.wrap = true
o.linebreak = true -- Wrap lines at 'breakat' (if 'wrap' is set)
o.breakindent = true -- Indent wrapped lines to match line start
o.breakindentopt = "list:-1" -- Add padding for lists (if 'wrap' is set)
o.relativenumber = false
o.cursorcolumn = true

local opt = vim.opt
opt.fillchars = {
  foldopen = user_preferences.icons.foldopen,
  foldclose = user_preferences.icons.foldclose,
  fold = " ",
  foldsep = " ",
  foldinner = " ",
  diff = "╱",
  eob = " ",
}
opt.listchars = {
  trail = "·",
  tab = "> ",
  eol = " ",
}

vim.cmd("packadd nvim.undotree")

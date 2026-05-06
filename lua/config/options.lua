-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_blink_main = true
vim.g.ai_cmp = false
vim.g.snacks_animate = false
vim.g.trouble_lualine = true
vim.g.lazyvim_ts_lsp = "tsgo"

local user_preferences = require("user_preferences")

local opt = vim.opt
opt.winborder = "rounded"
opt.cmdheight = 0
opt.pumblend = 0
opt.wrap = true
opt.linebreak = true -- Wrap lines at 'breakat' (if 'wrap' is set)
opt.breakindent = true -- Indent wrapped lines to match line start
opt.breakindentopt = "list:-1" -- Add padding for lists (if 'wrap' is set)
opt.relativenumber = false
opt.cursorcolumn = true
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
opt.foldcolumn = "1"
opt.showbreak = "↪"

-- Cursor appearance and blinking
opt.guicursor = table.concat({
  "n-v-c-sm:block-TermCursor", -- Normal, Visual, Command, Showmatch: block cursor
  "i-ci-ve:ver25-TermCursor", -- Insert, Command-insert, Visual-exclusive: vertical bar (25% width)
  "r-cr-o:hor20-TermCursor", -- Replace, Command-replace, Operator-pending: horizontal bar (20% height)
  "a:blinkwait500-blinkoff500-blinkon500",
}, ",")

vim.cmd("packadd nvim.undotree")

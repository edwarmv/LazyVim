-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_blink_main = true
vim.g.ai_cmp = false
vim.g.snacks_animate = false

local opt = vim.opt
opt.winborder = "rounded"
opt.pumblend = 0
opt.wrap = true
opt.linebreak = false -- Wrap lines at 'breakat' (if 'wrap' is set)
opt.breakindent = true -- Indent wrapped lines to match line start
opt.breakindentopt = "list:-1" -- Add padding for lists (if 'wrap' is set)
opt.statuscolumn = ""
opt.relativenumber = false
opt.showmode = true
opt.showcmd = true
opt.fillchars = {
  foldopen = "▼",
  foldclose = "▶",
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
-- opt.showbreak = "↪"

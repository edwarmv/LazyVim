-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_blink_main = true
vim.g.snacks_animate = false
vim.g.trouble_lualine = false
vim.g.lazyvim_ts_lsp = "tsgo"
vim.g.use_incline = false
vim.g.use_bufferline = true
vim.g.use_noice = false

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
opt.statuscolumn = ""
opt.fillchars = {
  foldopen = user_preferences.icons.foldopen,
  foldclose = user_preferences.icons.foldclose,
  fold = " ",
  foldsep = " ",
  foldinner = " ",
  diff = "╱",
  eob = "·",
}
opt.listchars = {
  trail = "·",
  tab = "> ",
  eol = " ",
}
opt.foldcolumn = "1"
opt.showbreak = "↪"

vim.cmd("packadd nvim.undotree")

if not vim.g.vscode and not vim.g.use_noice then
  require("vim._core.ui2").enable({
    msg = {
      targets = {
        undo = "msg",
        bufwrite = "msg",
      },
      msg = {
        timeout = 4000,
      },
    },
  })
end

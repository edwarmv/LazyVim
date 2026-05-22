return {
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      vim.g.loaded_nvim_treesitter = 1
    end,
  },
  {
    "lewis6991/ts-install.nvim",
    dependencies = "nvim-treesitter",
    opts = {
      install_dir = vim.fn.stdpath("data") .. "/site",
      auto_install = true,
      parsers = {
        plantuml = {
          url = "https://github.com/bemyak/tree-sitter-plantuml",
          branch = "master",
        },
      },
    },
  },
}

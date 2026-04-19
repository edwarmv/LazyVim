return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          local parsers = require("nvim-treesitter.parsers")
          parsers.plantuml = {
            install_info = {
              url = "https://github.com/bemyak/tree-sitter-plantuml",
              branch = "master",
              queries = "queries/plantuml",
            },
          }
        end,
      })

      vim.list_extend(opts.ensure_installed, {
        "bash",
        "c",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      })

      return opts
    end,
  },
}

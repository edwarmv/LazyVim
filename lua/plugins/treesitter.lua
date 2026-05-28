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

      local my_opts = {}

      return vim.tbl_deep_extend("force", opts or {}, my_opts)
    end,
  },
}

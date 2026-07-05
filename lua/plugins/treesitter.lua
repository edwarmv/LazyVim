return {
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = false,
    opts = {
      indent = {
        enable = false,
      },
    },
  },
  {
    "romus204/tree-sitter-manager.nvim",
    vscode = true,
    init = function()
      if LazyVim.set_default("foldmethod", "expr") then
        LazyVim.set_default("foldexpr", "v:lua.LazyVim.treesitter.foldexpr()")
      end
    end,
    opts = {
      auto_install = true,
      languages = {
        plantuml = {
          install_info = {
            url = "https://github.com/bemyak/tree-sitter-plantuml",
            queries = "queries/plantuml",
            use_repo_queries = true,
          },
        },
      },
    },
  },
}

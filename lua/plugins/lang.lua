return {
  { -- Markdown
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        code = {
          border = "thin",
        },
        -- win_options = {
        --   conceallevel = {
        --     rendered = 0,
        --   },
        -- },
        -- overrides = {
        --   buftype = {
        --     nofile = {
        --       code = {
        --         style = "normal",
        --       },
        --     },
        --   },
        -- },
      },
    },
    {
      "yousefhadder/markdown-plus.nvim",
      ft = "markdown",
      opts = {},
    },
  },
  {
    "charlesnicholson/plantuml.nvim",
    dependencies = {
      "nvim-treesitter",
      opts = {
        ensure_installed = {
          "plantuml",
        },
      },
    },
    opts = {
      auto_start = true,
      auto_update = true,
      http_port = 8764,
      plantuml_server_url = "http://www.plantuml.com/plantuml",
      auto_launch_browser = "never",
    },
  },
}

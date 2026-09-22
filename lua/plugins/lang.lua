return {
  { -- Markdown
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        code = {
          border = "thin",
        },
        heading = {
          sign = true,
          icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        },
        anti_conceal = {
          disabled_modes = { "n" },
        },
        win_options = {
          concealcursor = {
            rendered = "n",
          },
        },
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
    dependencies = { "aklt/plantuml-syntax" },
    opts = {
      auto_start = true,
      auto_update = true,
      http_port = 8764,
      plantuml_server_url = "http://www.plantuml.com/plantuml",
      auto_launch_browser = "never",
    },
  },
  {
    "Owen-Dechow/videre.nvim",
    cmd = "Videre",
    dependencies = {
      "Owen-Dechow/graph_view_yaml_parser",
      "Owen-Dechow/graph_view_toml_parser",
      "a-usr/xml2lua.nvim",
    },
    opts = {
      box_style = vim.o.winborder,
    },
    keys = {
      { "<leader>cg", "<cmd>Videre<cr>", ft = { "json", "yaml", "toml", "xml" }, desc = "View As Graph" },
    },
  },
}

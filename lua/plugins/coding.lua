return {
  {
    "saghen/blink.pairs",
    enabled = false,
    build = "cargo build --release",
    event = "InsertEnter",
    opts = {},
  },
  {
    "windwp/nvim-autopairs",
    enabled = true,
    event = "InsertEnter",
    opts = {},
  },
  {
    "saghen/blink.cmp",
    dependencies = {
      "saghen/blink.lib",
    },
    optional = true,
    build = function()
      require("blink.cmp").build():wait(60000)
    end,
    opts = function(_, opts)
      local icons = vim.deepcopy(LazyVim.config.icons.kinds)

      local my_opts = {
        keymap = {
          preset = "enter",
          ["<C-y>"] = { "select_and_accept" },
          ["<C-e>"] = { "cancel", "fallback" },
          ["<Tab>"] = {
            LazyVim.cmp.map({ "ai_nes", "ai_accept" }),
            "fallback",
          },
          ["<S-Tab>"] = false,
          ["<C-h>"] = { "snippet_backward", "fallback" },
          ["<C-l>"] = { "snippet_forward", "fallback" },
          ["<C-S-space>"] = {
            function(cmp)
              cmp.show({ providers = { "lsp" } })
            end,
          },
        },
        appearance = {
          kind_icons = vim.tbl_map(function(value)
            return value:sub(1, -2)
          end, icons),
        },
        sources = {
          providers = {
            lsp = {
              opts = { tailwind_color_icon = "" },
              fallbacks = {},
            },
            snippets = {
              opts = {
                extended_filetypes = {
                  typescript = { "javascript" },
                  astro = { "javascript" },
                },
              },
            },
            buffer = {
              score_offset = -5,
            },
          },
        },
        completion = {
          list = {
            selection = {
              preselect = false,
              auto_insert = true,
            },
          },
          trigger = {
            show_on_backspace = true,
            show_on_backspace_in_keyword = true,
            show_on_insert = true,
          },
          documentation = {
            window = {
              border = "padded",
            },
          },
          menu = {
            border = "none",
            draw = {
              padding = 1,
            },
          },
        },
        fuzzy = {
          sorts = {
            "score",
            "sort_text",
            "label",
          },
        },
      }

      return vim.tbl_deep_extend("force", opts or {}, my_opts)
    end,
  },
  {
    "nvim-mini/mini.pairs",
    enabled = false,
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },
  {
    "nvim-mini/mini.ai",
    enabled = false,
    opts = function(_, opts)
      opts.custom_textobjects.t = false
    end,
  },
  {
    "gbprod/yanky.nvim",
    dependencies = {
      enabled = not vim.g.vscode,
      "kkharji/sqlite.lua",
    },
    opts = {
      ring = {
        history_length = 1000,
        storage = vim.g.vscode and "shada" or "sqlite",
      },
    },
  },
  {
    "bchmnn/Comment.nvim",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      opts = {
        languages = {
          less = { __default = "// %s", __multiline = "/* %s */" },
        },
      },
    },
    opts = function()
      local ft = require("Comment.ft")
      ft.set("htmlangular", { "<!-- %s -->", "<!-- %s -->" })

      return {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },
  {
    "folke/ts-comments.nvim",
    enabled = false,
  },
  {
    "Wansmer/treesj",
    keys = {
      {
        "gS",
        function()
          require("treesj").split()
        end,
        desc = "Split code block",
      },
      {
        "gJ",
        function()
          require("treesj").join()
        end,
        desc = "Join code block",
      },
    },
    opts = {
      use_default_keymaps = false,
    },
  },
}

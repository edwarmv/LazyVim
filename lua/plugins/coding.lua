local user_preferences = require("user_preferences")

return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    "nvim-mini/mini.pairs",
    enabled = false,
  },
  {
    "saghen/blink.cmp",
    dependencies = {
      "saghen/blink.lib",
    },
    event = false,
    build = function()
      require("blink.cmp").build():pwait()
    end,
    opts = function(_, opts)
      local icons = vim.deepcopy(LazyVim.config.icons.kinds)

      local my_opts = {
        keymap = {
          ["<C-e>"] = { "cancel", "fallback" },
          ["<S-space>"] = {
            function(cmp)
              cmp.show({ providers = { "lsp" } })
            end,
          },
          ["<C-s>"] = { "show_signature", "hide_signature", "fallback" },
          ["<C-y>"] = { "select_and_accept", "fallback" },
          ["<C-k>"] = false,
        },
        appearance = {
          kind_icons = vim.tbl_map(function(value)
            return value:sub(1, -2)
          end, icons),
        },
        sources = {
          providers = {
            lsp = {
              opts = { tailwind_color_icon = user_preferences.icons.color },
              fallbacks = {},
            },
            snippets = {
              opts = {
                extended_filetypes = {
                  typescript = { "javascript" },
                  astro = { "javascript" },
                  typescriptreact = { "javascript" },
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
            },
          },
          trigger = {
            show_on_backspace = true,
            show_on_backspace_in_keyword = true,
          },
          menu = {
            border = "none",
          },
        },
        signature = { enabled = true },
      }

      return vim.tbl_deep_extend("force", opts or {}, my_opts)
    end,
  },
  {
    "kylechui/nvim-surround",
    vscode = true,
    event = "VeryLazy",
    opts = {},
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

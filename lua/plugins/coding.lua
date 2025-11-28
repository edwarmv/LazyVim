return {
  {
    "L3MON4D3/LuaSnip",
    opts = function(_, opts)
      local ls = require("luasnip")
      ls.filetype_extend("typescript", { "javascript" })
      ls.filetype_extend("astro", { "javascript" })
      opts.update_events = { "TextChanged", "TextChangedI" }
      opts.region_check_events = "CursorMoved"
      opts.delete_check_events = { "TextChanged" }
    end,
  },
  {
    "saghen/blink.cmp",
    enabled = false,
    opts = {
      keymap = {
        preset = "default",
      },
      appearance = {
        kind_icons = {
          Text = "",
          Method = "",
          Function = "",
          Constructor = "",
          Field = "",
          Variable = "",
          Class = "",
          Interface = "",
          Module = "",
          Property = "",
          Unit = "",
          Value = "",
          Enum = "",
          Keyword = "",
          Snippet = "",
          Color = "",
          File = "",
          Reference = "",
          Folder = "",
          EnumMember = "",
          Constant = "",
          Struct = "",
          Event = "",
          Operator = "",
          TypeParameter = "",
        },
      },
      sources = {
        providers = {
          lsp = {
            opts = { tailwind_color_icon = "" },
            fallbacks = {},
          },
          -- snippets = {
          --   opts = {
          --     extended_filetypes = {
          --       typescript = { "javascript" },
          --       astro = { "javascript" },
          --     },
          --   },
          -- },
          buffer = {
            max_items = 5,
          },
        },
      },
      completion = {
        list = {
          selection = {
            preselect = true,
            auto_insert = true,
          },
        },
        trigger = {
          show_on_backspace = true,
          show_on_backspace_in_keyword = true,
        },
        documentation = {
          window = {
            border = nil,
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
          "exact",
          "score",
          "kind",
          "sort_text",
          "label",
        },
      },
    },
  },
  {
    "nvim-mini/mini.pairs",
    enabled = false,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "windwp/nvim-autopairs",
        event = "VeryLazy",
        opts = {},
      },
      {
        "eeeXun/lspkind-nvim",
        branch = "cmp-icon-kind",
        opts = {
          preset = "codicons",
        },
      },
    },
    opts = function(_, opts)
      opts.window = {
        completion = {
          border = "none",
        },
        documentation = {
          border = "none",
        },
      }
      local lspkind = require("lspkind")
      opts.formatting = {
        format = lspkind.cmp_format({
          maxwidth = {
            -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            -- can also be a function to dynamically calculate max width such as
            -- menu = function() return math.floor(0.45 * vim.o.columns) end,
            menu = 50, -- leading text (labelDetails)
            abbr = 50, -- actual suggestion item
          },
          ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
          show_labelDetails = true, -- show labelDetails in menu. Disabled by default

          -- The function below will be called before any actual modifications from lspkind
          -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
          before = function(entry, vim_item)
            -- ...
            return vim_item
          end,
        }),
      }
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },
  {
    "nvim-mini/mini.ai",
    opts = function(_, opts)
      opts.custom_textobjects.t = false
    end,
  },
  {
    "gbprod/yanky.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
    },
    opts = {
      ring = {
        storage = "sqlite",
      },
    },
  },
  {
    "numToStr/Comment.nvim",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    event = "VeryLazy",
    opts = function()
      return {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },
  {
    "folke/ts-comments.nvim",
    enabled = false,
  },
}

return {
  {
    "L3MON4D3/LuaSnip",
    optional = true,
    event = "VeryLazy",
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
    "nvim-mini/mini.snippets",
    optional = true,
    opts = function(_, opts)
      -- By default, for opts.snippets, the extra for mini.snippets only adds gen_loader.from_lang()
      -- This provides a sensible quickstart, integrating with friendly-snippets
      -- and your own language-specific snippets
      --
      -- In order to change opts.snippets, replace the entire table inside your own opts

      local snippets, config_path = require("mini.snippets"), vim.fn.stdpath("config")

      local javascript = "**/javascript.json"
      local react = "**/react.json"
      local lang_patterns = {
        typescript = { javascript },
        astro = { javascript },
        tsx = { react, javascript },
      }
      opts.snippets = { -- override opts.snippets provided by extra...
        -- Load custom file with global snippets first (order matters)
        snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),

        -- Load snippets based on current language by reading files from
        -- "snippets/" subdirectories from 'runtimepath' directories.
        snippets.gen_loader.from_lang({
          lang_patterns = lang_patterns,
        }), -- this is the default in the extra...
      }
    end,
  },
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = {
      {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {},
      },
    },
    opts = function()
      local icons = vim.deepcopy(LazyVim.config.icons.kinds)

      return {
        keymap = {
          preset = "enter",
          ["<C-y>"] = { "select_and_accept" },
          ["<C-e>"] = { "cancel", "fallback" },
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
    end,
  },
  {
    "nvim-mini/mini.pairs",
    enabled = false,
  },
  {
    "hrsh7th/nvim-cmp",
    optional = false,
    dependencies = {
      {
        "windwp/nvim-autopairs",
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
        storage = vim.g.vscode and "shada" or "sqlite",
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

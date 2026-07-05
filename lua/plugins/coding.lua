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
    "L3MON4D3/LuaSnip",
    optional = true,
    opts = function(_, opts)
      local ls = require("luasnip")
      ls.filetype_extend("typescript", { "javascript", "tsdoc" })
      ls.filetype_extend("javascript", { "jsdoc" })
      ls.filetype_extend("astro", { "javascript" })
      ls.filetype_extend("typescriptreact", { "javascript", "tsdoc", "react-es7", "react-ts", "next-ts" })
      ls.filetype_extend("lua", { "luadoc" })
      opts.update_events = { "TextChanged", "TextChangedI" }
      opts.region_check_events = "CursorMoved"
      opts.delete_check_events = { "TextChanged" }
    end,
  },
  {
    "nvim-mini/mini.snippets",
    optional = true,
    opts = function(_, opts)
      local snippets = require("mini.snippets")
      local config_path = vim.fn.stdpath("config")
      local lang_patterns = {
        typescript = { "**/javascript.json", "**/tsdoc.json" },
        astro = { "**/javascript.json" },
        tsx = {
          "**/javascript.json",
          "**/tsdoc.json",
          "**/react-es7.json",
          "**/react-ts.json",
          "**/next-ts.json",
        },
      }
      opts.snippets = {
        snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
        snippets.gen_loader.from_lang({
          lang_patterns = lang_patterns,
        }),
      }
      -- Stop all sessions on Normal mode exit
      local make_stop = function()
        local au_opts = { pattern = "*:n", once = true }
        au_opts.callback = function()
          while MiniSnippets.session.get() do
            MiniSnippets.session.stop()
          end
        end
        vim.api.nvim_create_autocmd("ModeChanged", au_opts)
      end
      -- Stop session immediately after jumping to final tabstop
      vim.api.nvim_create_autocmd("User", { pattern = "MiniSnippetsSessionStart", callback = make_stop })
      local fin_stop = function(args)
        if args.data.tabstop_to == "0" then
          MiniSnippets.session.stop()
        end
      end
      vim.api.nvim_create_autocmd("User", { pattern = "MiniSnippetsSessionJump", callback = fin_stop })
    end,
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
          ["<C-y>"] = { "select_and_accept", "fallback" },
          ["<Tab>"] = {
            LazyVim.cmp.map({ "ai_nes", "ai_accept" }),
            "fallback",
          },
          ["<S-Tab>"] = false,
          ["<C-h>"] = { "snippet_backward", "fallback" },
          ["<C-l>"] = { "snippet_forward", "fallback" },
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
                  typescript = { "javascript", "tsdoc" },
                  javascript = { "jsdoc" },
                  astro = { "javascript" },
                  typescriptreact = { "javascript", "tsdoc", "react-es7", "react-ts", "next-ts" },
                  lua = { "luadoc" },
                },
              },
            },
            buffer = {
              score_offset = -5,
            },
          },
        },
        cmdline = { enabled = false },
        completion = {
          list = {
            selection = {
              preselect = true,
              auto_insert = false,
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
        fuzzy = {
          sorts = {
            "exact",
            "score",
            "sort_text",
          },
        },
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
    "numToStr/Comment.nvim",
    init = function()
      -- Fixes a bug with which-key where user can not execute gcc
      vim.keymap.del({ "o", "n", "x" }, "gc")
    end,
    event = "VeryLazy",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      opts = {
        enable_autocmd = false,
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

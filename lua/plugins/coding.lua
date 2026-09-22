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
    event = "VeryLazy",
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
    keys = {
      {
        "<C-J>",
        function()
          local ls = require("luasnip")
          ls.expand()
        end,
        mode = { "i" },
        desc = "Expand snippet",
      },
    },
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
    optional = true,
    dependencies = {
      "saghen/blink.lib",
    },
    build = function()
      require("blink.cmp").download({ force = true, match = "*" }):pwait()
    end,
    opts = function(_, opts)
      local icons = vim.deepcopy(LazyVim.config.icons.kinds)

      local my_opts = {
        keymap = {
          ["<C-e>"] = { "cancel", "fallback" },
          ["<C-y>"] = { "select_and_accept", "fallback" },
          ["<Tab>"] = {
            LazyVim.cmp.map({ "ai_nes", "ai_accept" }),
            "fallback",
          },
          ["<S-Tab>"] = false,
          ["<C-h>"] = { "snippet_backward", "fallback" },
          ["<C-l>"] = { "snippet_forward", "fallback" },
          ["<M-Space>"] = {
            function(cmp)
              return cmp.show({ providers = { "lsp" } })
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
        completion = {
          list = {
            selection = {
              preselect = false,
              auto_insert = false,
            },
          },
          menu = {
            border = "none",
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
    "celeste3z/celeste_comment.nvim",
    lazy = false,
    init = function()
      -- Fixes a bug with which-key where user can not execute gcc
      vim.keymap.del({ "o", "n", "x" }, "gc")
    end,
    opts = {
      mappings = {
        line_add_below = "gco",
        line_add_above = "gcO",
        line_add_eol = "gcA",
      },
    },
  },
  --[[ {
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
  }, ]]
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

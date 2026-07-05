return {
  {
    "olimorris/codecompanion.nvim",
    version = "*",
    cmd = {
      "CodeCompanion",
      "CodeCompanionChat",
      "CodeCompanionCmd",
      "CodeCompanionActions",
    },
    opts = function()
      return {
        strategies = {
          chat = {
            adapter = "copilot",
            keymaps = {
              clear = {
                modes = {
                  n = "gX",
                },
                index = 6,
                callback = "keymaps.clear",
                description = "Clear Chat",
              },
            },
          },
          inline = {
            adapter = "copilot",
          },
        },
        adapters = {
          http = {
            ["gpt-oss"] = function()
              return require("codecompanion.adapters").extend("openai_compatible", {
                env = {
                  url = "http://localhost:1234", -- optional: default value is ollama url http://127.0.0.1:11434
                  chat_url = "/v1/chat/completions", -- optional: default value, override if different
                  models_endpoint = "/v1/models", -- optional: attaches to the end of the URL to form the endpoint to retrieve models
                },
                schema = {
                  model = {
                    default = "openai/gpt-oss-20b", -- define llm model to be used
                  },
                },
              })
            end,
          },
        },
        extensions = {
          history = {
            enabled = true,
          },
        },
      }
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/codecompanion-history.nvim",
    },
    keys = {
      {
        "<C-S-.>",
        "<cmd>CodeCompanionChat Toggle<cr>",
        mode = { "n", "v" },
        noremap = true,
        silent = true,
        desc = "CodeCompanion Toggle",
      },
      { "<leader>ac", "", desc = "Code Companion" },
      {
        "<leader>aca",
        "<cmd>CodeCompanionActions<cr>",
        mode = { "n", "v" },
        noremap = true,
        silent = true,
        desc = "CodeCompanion Actions",
      },
      {
        "<leader>acA",
        "<cmd>CodeCompanionChat Add<cr>",
        mode = { "v" },
        noremap = true,
        silent = true,
        desc = "CodeCompanion Add",
      },
    },
  },
  {
    "yetone/avante.nvim",
    optional = true,
    opts = {
      provider = "gpt-oss",
      providers = {
        ["gpt-oss"] = {
          __inherited_from = "openai",
          endpoint = "http://localhost:1234/v1",
          model = "openai/gpt-oss-20b",
          extra_request_body = {
            max_completion_tokens = 131072,
            max_tokens = 131072,
          },
        },
      },
    },
  },
  {
    {
      "folke/sidekick.nvim",
      optional = true,
      opts = {
        cli = {
          mux = {
            enabled = true,
            create = "split",
          },
          tools = {
            opencode = {
              keys = { prompt = { "<a-p>", "prompt" } },
            },
          },
        },
      },
      keys = {
        {
          "<c-.>",
          function()
            require("sidekick.cli").toggle({ name = "opencode" })
          end,
          desc = "Sidekick Toggle",
          mode = { "n", "t", "i", "x" },
        },
        {
          "<leader>aa",
          function()
            require("sidekick.cli").toggle({ name = "opencode" })
          end,
          desc = "Sidekick Toggle CLI",
        },
      },
    },
    {
      "nvim-lualine/lualine.nvim",
      optional = true,
      opts = function(_, opts)
        opts.options.disabled_filetypes.winbar =
          vim.list_extend(opts.options.disabled_filetypes.winbar or {}, { "sidekick_terminal" })
      end,
    },
  },
  {
    "zbirenbaum/copilot.lua",
    optional = true,
    opts = {},
  },
  {
    "piersolenski/wtf.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "folke/snacks.nvim",
    },
    opts = {
      provider = "copilot",
      providers = {
        copilot = {
          model_id = "claude-sonnet-4.5",
        },
      },
      picker = "snacks",
    },
    keys = {
      { "<C-w><C-d>", "", desc = "Diagnostics With AI" },
      {
        "<C-w><C-d>d",
        mode = { "n", "x" },
        function()
          require("wtf").diagnose()
        end,
        desc = "Debug diagnostic with AI",
      },
      {
        "<C-w><C-d>f",
        mode = { "n", "x" },
        function()
          require("wtf").fix()
        end,
        desc = "Fix diagnostic with AI",
      },
      {
        mode = { "n" },
        "<C-w><C-d>s",
        function()
          require("wtf").search()
        end,
        desc = "Search diagnostic with Google",
      },
      {
        mode = { "n" },
        "<C-w><C-d>p",
        function()
          require("wtf").pick_provider()
        end,
        desc = "Pick provider",
      },
      {
        mode = { "n" },
        "<C-w><C-d>h",
        function()
          require("wtf").history()
        end,
        desc = "Populate the quickfix list with previous chat history",
      },
      {
        mode = { "n" },
        "<C-w><C-d>g",
        function()
          require("wtf").grep_history()
        end,
        desc = "Grep previous chat history with picker",
      },
      {
        "<C-w><C-d>y",
        mode = { "n", "x" },
        function()
          require("wtf").yank()
        end,
        desc = "Yank diagnostic to clipboard",
      },
    },
  },
}

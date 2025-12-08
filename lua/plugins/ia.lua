return {
  {
    "olimorris/codecompanion.nvim",
    version = "v17.33.0",
    opts = function()
      return {
        strategies = {
          chat = {
            adapter = "gpt-oss",
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
            adapter = "gemini",
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
      }
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      {
        "<localleader>at",
        "<cmd>CodeCompanionChat Toggle<cr>",
        mode = { "n", "v" },
        noremap = true,
        silent = true,
        desc = "CodeCompanion Toggle",
      },
      {
        "<localleader>aa",
        "<cmd>CodeCompanionActions<cr>",
        mode = { "n", "v" },
        noremap = true,
        silent = true,
        desc = "CodeCompanion Actions",
      },
      {
        "<localleader>aA",
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
}

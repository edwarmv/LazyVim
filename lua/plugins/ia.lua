return {
  {
    "olimorris/codecompanion.nvim",
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
      { "<localleader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "CodeCompanion Toggle" },
      { "<localleader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions" },
      { "<localleader>aA", "<cmd>CodeCompanionChat Add<cr>", mode = { "v" }, desc = "CodeCompanion Add" },
    },
  },
}

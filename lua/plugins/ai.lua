local model = vim.env.OPENAI_MODEL or "gpt-5.6-luna"
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
        interactions = {
          chat = {
            adapter = {
              name = "copilot",
              model = model,
            },
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
            adapter = {
              name = "copilot",
              model = model,
            },
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
    opts = {},
  },
  {
    {
      "folke/sidekick.nvim",
      optional = true,
      opts = {
        cli = {
          mux = {
            enabled = vim.env.TMUX ~= nil,
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
            require("sidekick.cli").toggle()
          end,
          desc = "Sidekick Toggle",
          mode = { "n", "t", "i", "x" },
        },
        {
          "<leader>aa",
          function()
            require("sidekick.cli").toggle()
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
          model_id = "claude-sonnet-5",
        },
      },
      picker = "snacks",
    },
    keys = {
      { "<leader>aD", "", desc = "Diagnostics With AI" },
      {
        "<leader>aDd",
        mode = { "n", "x" },
        function()
          require("wtf").diagnose()
        end,
        desc = "Debug diagnostic with AI",
      },
      {
        "<leader>aDf",
        mode = { "n", "x" },
        function()
          require("wtf").fix()
        end,
        desc = "Fix diagnostic with AI",
      },
      {
        mode = { "n" },
        "<leader>aDs",
        function()
          require("wtf").search()
        end,
        desc = "Search diagnostic with Google",
      },
      {
        mode = { "n" },
        "<leader>aDp",
        function()
          require("wtf").pick_provider()
        end,
        desc = "Pick provider",
      },
      {
        mode = { "n" },
        "<leader>aDh",
        function()
          require("wtf").history()
        end,
        desc = "Populate the quickfix list with previous chat history",
      },
      {
        mode = { "n" },
        "<leader>aDg",
        function()
          require("wtf").grep_history()
        end,
        desc = "Grep previous chat history with picker",
      },
      {
        "<leader>aDy",
        mode = { "n", "x" },
        function()
          require("wtf").yank()
        end,
        desc = "Yank diagnostic to clipboard",
      },
    },
  },
}

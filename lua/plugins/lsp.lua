local user_preferences = require("user_preferences")
local function resizeGotoPreview()
  require("goto-preview").setup({
    width = math.floor(vim.o.columns / 2),
    height = math.floor(vim.o.lines / 3),
  })
end

return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "astro-language-server",
        "emmet-language-server",
        "css-variables-language-server",
        "bash-language-server",
        "some-sass-language-server",
        "tailwindcss-language-server",
        "vim-language-server",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "dnlhc/glance.nvim",
        cmd = "Glance",
        opts = function()
          local glance = require("glance")
          local actions = glance.actions

          return {
            preview_win_opts = {
              wrap = false,
            },
            detached = function(winid)
              return true
            end,
            folds = {
              fold_closed = user_preferences.icons.foldclose,
              fold_open = user_preferences.icons.foldopen,
            },
            indent_lines = {
              enable = false,
            },
            mappings = {
              list = {
                ["v"] = false,
                ["s"] = false,
                ["t"] = false,
                ["<c-v>"] = actions.jump_vsplit,
                ["<c-s>"] = actions.jump_split,
                ["<c-t>"] = actions.jump_tab,
              },
            },
          }
        end,
      },
      {
        "rmagatti/goto-preview",
        event = "LspAttach",
        opts = {
          width = math.floor(vim.o.columns / 2),
          height = math.floor(vim.o.lines / 3),
          references = {
            provider = "snacks",
          },
          default_mappings = false,
          border = vim.o.winborder,
        },
      },
    },
    opts = {
      diagnostics = {
        virtual_text = {
          current_line = true,
        },
      },
      inlay_hints = {
        enabled = false,
      },
      folds = {
        enabled = true,
      },
      servers = {
        ["*"] = {
          -- on_attach = function(_, bufnr)
          --   vim.lsp.document_color.enable(true, bufnr, { style = " " })
          -- end,
          keys = {
            {
              "gK",
              false,
            },
            {
              "<C-k>",
              mode = { "i" },
              false,
            },
            {
              "<C-s>",
              function()
                return vim.lsp.buf.signature_help()
              end,
              mode = { "i", "x", "n", "s" },
              desc = "Signature Help",
              has = "signatureHelp",
            },
            { "gr", false },
            {
              "grr",
              function()
                Snacks.picker.lsp_references({ include_current = true })
              end,
              desc = "References",
            },
            {
              "<leader>cr",
              require("lsp.rename").lsp_buf_rename,
              desc = "Rename",
              has = "rename",
            },
            { "grn", "<leader>cr", desc = "Rename", remap = true },
            { "glr", "<cmd>Glance references<cr>", desc = "[LSP - Glance] References" },
            { "gld", "<cmd>Glance definitions<cr>", desc = "[LSP - Glance] Definitions" },
            { "glt", "<cmd>Glance type_definitions<cr>", desc = "[LSP - Glance] Type Definitions" },
            { "gli", "<cmd>Glance implementations<cr>", desc = "[LSP - Glance] Implementations" },
            {
              "glpd",
              function()
                resizeGotoPreview()
                require("goto-preview").goto_preview_definition()
              end,
              desc = "[LSP] Goto Preview Definition",
            },
            {
              "glpt",
              function()
                resizeGotoPreview()
                require("goto-preview").goto_preview_type_definition()
              end,
              desc = "[LSP] Goto Preview Type Definition",
            },
            {
              "glpi",
              function()
                resizeGotoPreview()
                require("goto-preview").goto_preview_implementation()
              end,
              desc = "[LSP] Goto Preview Implementation",
            },
            {
              "glpr",
              function()
                resizeGotoPreview()
                require("goto-preview").goto_preview_references()
              end,
              desc = "[LSP] Goto Preview References",
            },
            {
              "glpq",
              function()
                require("goto-preview").close_all_win()
              end,
              desc = "[LSP] Goto Preview Close All Win",
            },
          },
        },
        ["html"] = {
          filetypes = { "html", "templ", "htmlangular" },
        },
        ["cssls"] = {
          filetypes = { "css", "less" },
          settings = {
            scss = {
              validate = false,
            },
          },
        },
      },
      setup = {
        angularls = function()
          Snacks.util.lsp.on({ name = "angularls" }, function(_, client)
            client.server_capabilities.renameProvider = true
          end)
        end,
      },
    },
  },
}

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections.lualine_b[1] = {
        "branch",
        fmt = function(value)
          if value ~= "" then
            local max_width = vim.o.columns * 1 / 5
            return string.len(value) <= max_width and value or string.sub(value, 1, max_width) .. "…"
          end
          return ""
        end,
      }
      table.insert(opts.sections.lualine_y, 1, { "filetype" })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        mode = "tabs",
        separator_style = "slant",
        show_close_icon = false,
        show_buffer_close_icons = false,
        truncate_names = true,
        numbers = "ordinal",
      },
    },
    keys = {
      { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick Buffer" },
      { "<leader>bP", false },
      { "<leader>bj", false },
      { "<leader>bc", "<CMD>BufferLinePickClose<CR>", desc = "Pick Tab to Close" },
    },
  },
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        hover = {
          enabled = false,
          silent = true,
        },
        signature = {
          enabled = false,
        },
      },
      -- Configuration for native cmdline popup
      presets = {
        command_palette = false,
      },
      views = {
        popupmenu = {
          border = {
            style = "none",
            padding = { 0, 1 },
          },
        },
      },
      -- end of native cmdline popup configuration
    },
  },
  {
    "ntpeters/vim-better-whitespace",
    event = "VimEnter",
    init = function()
      vim.g.better_whitespace_enabled = 1
      vim.g.better_whitespace_operator = "<C-S-s>"
      vim.g.better_whitespace_filetypes_blacklist = { "dbout", "dashboard", "alpha", "snacks_dashboard" }
    end,
  },
  {
    "whatyouhide/vim-lengthmatters",
    cmd = {
      "LengthmattersToggle",
      "LengthmattersEnable",
      "LengthmattersDisable",
      "LengthmattersReload",
      "LengthmattersEnableAll",
      "LengthmattersDisableAll",
    },
    keys = {
      { "<leader><leader>ul", "<cmd>LengthmattersToggle<cr>", desc = "Toggle Lengthmatters" },
      { "<leader><leader>uL", "<cmd>LengthmattersReload<cr>", desc = "Reload Lengthmatters" },
    },
    config = function()
      vim.g.lengthmatters_on_by_default = 0
      vim.g.lengthmatters_highlight_one_column = 0
      vim.fn["lengthmatters#highlight_link_to"]("ColorColumn")
    end,
  },
  {
    "hankertrix/nerd_column.nvim",
    event = "BufEnter",
    opts = {
      scope = "window",
    },
  },
  {
    "b0o/incline.nvim",
    dependencies = {
      "nvim-mini/mini.icons",
    },
    opts = function()
      return {
        window = {
          padding = 1,
          margin = { horizontal = 0 },
          zindex = 35,
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end
          local ft_icon, ft_color = MiniIcons.get("file", filename)
          local modified = vim.bo[props.buf].modified

          return {
            ft_icon and { ft_icon, group = props.focused and ft_color or nil } or "",
            " ",
            { filename, gui = modified and "italic" or "" },
            modified and {
              " ●",
              guifg = props.focused and Snacks.util.color("LualineModifiedFilename") or nil,
              gui = "bold",
            } or "",
          }
        end,
        highlight = {
          groups = {
            InclineNormal = "StatusLine",
            InclineNormalNC = "StatusLineNC",
          },
        },
      }
    end,
    event = "VeryLazy",
  },
}

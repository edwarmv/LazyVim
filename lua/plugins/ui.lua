return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local icons = LazyVim.config.icons
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
      if not vim.g.use_incline then
        opts.sections.lualine_c[1] = "" -- Disable root dir
        opts.sections.lualine_c[2] = "" -- Disable diagnostics
        opts.sections.lualine_c[3] = "" -- Disable filetype
        opts.sections.lualine_c[4] = "" -- Disable filename
        opts.sections.lualine_x[8] = "" -- Disable diff
      end
      table.insert(opts.sections.lualine_y, 1, { "filetype" })

      if not vim.g.use_noice then
        local function macro()
          local reg = vim.fn.reg_recording()
          if reg ~= "" then
            return "Recording @" .. reg
          end
          return ""
        end
        table.insert(opts.sections.lualine_x, 2, {
          macro,
          color = function()
            return { fg = Snacks.util.color("Statement") }
          end,
        })
        table.insert(opts.sections.lualine_x, 3, "searchcount")
        table.insert(opts.sections.lualine_x, 4, "selectioncount")
      end

      if not vim.g.use_bufferline then
        opts.options.always_show_tabline = false
        opts.tabline = {
          lualine_a = {
            {
              "tabs",
              mode = 2,
              max_length = function()
                return vim.o.columns
              end,
            },
          },
        }
      end

      opts.options.disabled_filetypes.winbar = vim.list_extend(opts.options.disabled_filetypes.winbar or {}, {
        "qf",
      })
      local winbar_config = {
        lualine_c = {
          LazyVim.lualine.root_dir(),
          {
            "filetype",
            icon_only = true,
            padding = { left = 1, right = 0 },
            separator = "",
          },
          { -- Fallback for when no icon is available
            function()
              return " "
            end,
            cond = function()
              return vim.bo.filetype == ""
            end,
            padding = 0,
            separator = "",
          },
          {
            LazyVim.lualine.pretty_path({ filename_hl = "LualineFilename", modified_hl = "LualineModifiedFilename" }),
            padding = { left = 0, right = 1 },
            separator = "",
          },
          {
            "diff",
            padding = { left = 0, right = 1 },
            separator = "",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
          {
            "diagnostics",
            padding = { left = 0, right = 1 },
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
        },
      }

      if not vim.g.use_incline then
        opts.winbar = winbar_config
        opts.inactive_winbar = winbar_config
      end
    end,
  },
  {
    "akinsho/bufferline.nvim",
    enabled = vim.g.use_bufferline,
    opts = {
      options = {
        mode = "tabs",
        separator_style = "slant",
        show_close_icon = false,
        show_buffer_close_icons = false,
        truncate_names = false,
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
    enabled = vim.g.use_noice,
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
    "j-hui/fidget.nvim",
    enabled = not vim.g.use_noice,
    opts = {},
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
    enabled = vim.g.use_incline,
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

return {
  {
    "stevearc/quicker.nvim",
    enabled = false,
    ft = "qf",
    opts = {
      keys = {
        {
          ">",
          function()
            require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
          end,
          desc = "Expand quickfix context",
        },
        {
          "<",
          function()
            require("quicker").collapse()
          end,
          desc = "Collapse quickfix context",
        },
      },
    },
  },
  {
    "kevinhwang91/nvim-bqf",
    dependencies = {
      "junegunn/fzf",
      version = "*",
      build = "./install --bin",
    },
    enabled = true,
    ft = "qf",
    opts = {
      auto_enable = true,
      auto_resize_height = true,
      delay_syntax = 80,
      preview = {
        border = vim.o.winborder,
        winblend = 0,
        should_preview_cb = function(bufnr, qwinid)
          local ret = true
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          local fsize = vim.fn.getfsize(bufname)
          if fsize > 100 * 1024 then
            -- skip file size greater than 100k
            ret = false
          elseif bufname:match("^fugitive://") then
            -- skip fugitive buffer
            ret = false
          end
          return ret
        end,
      },
      filter = {
        fzf = {
          extra_opts = { "--bind", "ctrl-o:toggle-all", "--delimiter", "│" },
        },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    enabled = true,
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
      table.insert(opts.extensions, "toggleterm")
    end,
  },
  {
    "akinsho/bufferline.nvim",
    optional = true,
    opts = {
      options = {
        mode = "tabs",
        always_show_bufferline = false,
        separator_style = "slant",
        show_close_icon = false,
        show_buffer_close_icons = false,
        truncate_names = true,
        numbers = "ordinal",
      },
    },
    keys = {
      { "<leader>bp", "<CMD>BufferLinePickClose<CR>", desc = "Pick Tab to Close" },
      { "<leader>bP", false },
      { "<leader>br", false },
      { "<leader>bl", false },
      { "<S-h>", false },
      { "<S-l>", false },
      { "[b", false },
      { "]b", false },
      { "[B", false },
      { "]B", false },
    },
  },
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
          ["vim.lsp.util.stylize_markdown"] = false,
          ["cmp.entry.get_documentation"] = false,
        },
        hover = {
          enabled = false,
          silent = true,
        },
        signature = {
          enabled = false,
        },
      },
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
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { kind = "lua_error" },
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
    },
  },
  {
    "ntpeters/vim-better-whitespace",
    event = "VimEnter",
    init = function()
      vim.g.better_whitespace_enabled = 1
      vim.g.better_whitespace_operator = "<leader><leader>s"
      vim.g.better_whitespace_filetypes_blacklist = { "dbout", "dashboard", "alpha", "snacks_dashboard" }
    end,
  },
  {
    "Bekaboo/deadcolumn.nvim",
    event = "VeryLazy",
    init = function()
      vim.opt.colorcolumn = "80"
    end,
    opts = {},
  },
  {
    "b0o/incline.nvim",
    dependencies = {
      "nvim-mini/mini.icons",
    },
    opts = function()
      return {
        window = {
          padding = 0,
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
            ft_icon and { " ", ft_icon, group = props.focused and ft_color or "StatusLineNC" } or "",
            " ",
            { filename, gui = modified and "italic" or "" },
            " ",
          }
        end,
        hide = {
          focused_win = false,
        },
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

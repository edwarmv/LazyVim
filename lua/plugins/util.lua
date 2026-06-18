return {
  {
    {
      "akinsho/toggleterm.nvim",
      cmd = { "TTerm", "VTerm", "STerm", "FTerm" },
      opts = function()
        vim.api.nvim_create_user_command("FTerm", function(opts)
          vim.fn.execute(opts.count .. "ToggleTerm direction=float")
        end, { count = true })
        vim.api.nvim_create_user_command("VTerm", function(opts)
          vim.fn.execute(opts.count .. "ToggleTerm direction=vertical")
        end, { count = true })
        vim.api.nvim_create_user_command("STerm", function(opts)
          vim.fn.execute(opts.count .. "ToggleTerm direction=horizontal")
        end, { count = true })
        vim.api.nvim_create_user_command("TTerm", function(opts)
          vim.fn.execute(opts.count .. "ToggleTerm direction=tab")
        end, { count = true })

        function _G.set_terminal_keymaps()
          local esc_timer
          local opts = { buffer = 0 }
          vim.keymap.set("t", "<esc>", function()
            esc_timer = esc_timer or (vim.uv or vim.loop).new_timer()
            if esc_timer:is_active() then
              esc_timer:stop()
              vim.cmd("stopinsert")
            else
              esc_timer:start(200, 0, function() end)
              return "<esc>"
            end
          end, { buffer = 0, expr = true, desc = "Double escape to normal mode" })
          vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
          vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
          vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
          vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
        end

        vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")

        return {
          auto_scroll = false,
          size = function(term)
            if term.direction == "horizontal" then
              return math.floor((vim.o.lines - vim.o.cmdheight) / 3)
            elseif term.direction == "vertical" then
              return math.floor(vim.o.columns / 3)
            end
          end,
          direction = "horizontal", -- 'vertical' | 'horizontal' | 'window' | 'float',
          shade_terminals = false,
          float_opts = {
            border = vim.o.winborder,
            width = function()
              local width = math.floor(vim.o.columns * 0.75)
              return width
            end,
            height = function()
              local height = math.floor(vim.o.lines * 0.7)
              return height
            end,
          },
        }
      end,
      keys = {
        {
          mode = { "n", "t" },
          "<C-/>",
          function()
            local count = vim.v.count
            local root = LazyVim.root()
            vim.cmd(count .. "ToggleTerm dir=" .. root)
          end,
          desc = "ToggleTerm (root dir)",
        },
        {
          mode = { "n", "t" },
          "<C-_>",
          function()
            local count = vim.v.count
            local root = LazyVim.root()
            vim.cmd(count .. "ToggleTerm dir=" .. root)
          end,
          desc = "ToggleTerm (root dir)",
        },
        {
          mode = { "n", "t" },
          "<C-`>",
          function()
            local count = vim.v.count
            vim.fn.execute(count .. "ToggleTerm")
          end,
          desc = "ToggleTerm (cwd)",
        },
      },
    },
    {
      "nvim-lualine/lualine.nvim",
      optional = true,
      opts = function(_, opts)
        table.insert(opts.extensions, "toggleterm")
        opts.options.disabled_filetypes.winbar =
          vim.list_extend(opts.options.disabled_filetypes.winbar or {}, { "toggleterm" })
      end,
    },
  },
  {
    "mistricky/codesnap.nvim",
    cmd = { "CodeSnap", "CodeSnapSave" },
    opts = {
      snapshot_config = {
        window = {
          mac_window_bar = false,
          margin = {
            x = 12,
            y = 12,
          },
        },
        watermark = { content = "" },
      },
    },
  },
}

return {
  {
    "akinsho/toggleterm.nvim",
    lazy = false,
    init = function()
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
        vim.keymap.set("n", "gf", function()
          local f = vim.fn.findfile(vim.fn.expand("<cfile>"), "**")
          if f == "" then
            Snacks.notify.warn("No file under cursor")
          else
            vim.cmd("ToggleTerm")
            vim.schedule(function()
              vim.cmd("e " .. f)
            end)
          end
        end, opts)
      end

      vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")
    end,
    opts = {
      auto_scroll = false,
      size = function(term)
        if term.direction == "horizontal" then
          return math.floor((vim.o.lines - vim.o.cmdheight) / 3)
        elseif term.direction == "vertical" then
          return math.floor(vim.o.columns / 3)
        end
      end,
      open_mapping = [[<c-`>]],
      direction = "float", -- 'vertical' | 'horizontal' | 'window' | 'float',
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
    },
    keys = {
      {
        "<leader>tf",
        function()
          local count = vim.v.count1
          vim.fn.execute(count .. string.format("ToggleTerm dir=%s direction=float", LazyVim.root()))
        end,
        desc = "ToggleTerm - Float (root dir)",
      },
      {
        "<leader>tF",
        function()
          local count = vim.v.count1
          vim.fn.execute(count .. "ToggleTerm direction=float")
        end,
        desc = "ToggleTerm - Float (cwd)",
      },
      {
        "<leader>tv",
        function()
          local count = vim.v.count1
          vim.fn.execute(count .. string.format("ToggleTerm dir=%s direction=vertical", LazyVim.root()))
        end,
        desc = "ToggleTerm - Vertical (root dir)",
      },
      {
        "<leader>tV",
        function()
          local count = vim.v.count1
          vim.fn.execute(count .. "ToggleTerm direction=vertical")
        end,
        desc = "ToggleTerm - Vertical (cwd)",
      },
      {
        "<leader>ts",
        function()
          local count = vim.v.count1
          vim.fn.execute(count .. string.format("ToggleTerm dir=%s direction=horizontal", LazyVim.root()))
        end,
        desc = "ToggleTerm - Horizontal (root dir)",
      },
      {
        "<leader>tS",
        function()
          local count = vim.v.count1
          vim.fn.execute(count .. "ToggleTerm direction=horizontal")
        end,
        desc = "ToggleTerm - Horizontal (cwd)",
      },
      {
        "<leader>tt",
        function()
          local count = vim.v.count1
          vim.fn.execute(count .. string.format("ToggleTerm dir=%s direction=tab", LazyVim.root()))
        end,
        desc = "ToggleTerm - Tab (root dir)",
      },
      {
        "<leader>tT",
        function()
          local count = vim.v.count1
          vim.fn.execute(count .. "ToggleTerm direction=tab")
        end,
        desc = "ToggleTerm - Tab (cwd)",
      },
    },
  },
}

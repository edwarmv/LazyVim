return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>db",
        false,
      },
      {
        "<leader>dB",
        false,
      },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    opts = {
      floating = {
        border = vim.o.winborder,
      },
    },
    keys = {
      {
        "<leader>dU",
        function()
          require("dapui").toggle({ reset = true })
        end,
        desc = "Dap UI Reset",
      },
    },
  },
  {
    "Carcuis/dap-breakpoints.nvim",
    event = "BufReadPost",
    dependencies = {
      "Weissle/persistent-breakpoints.nvim",
      opts = {},
    },
    opts = {},
    keys = {
      {
        "<leader>db",
        function()
          require("dap-breakpoints.api").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap-breakpoints.api").set_breakpoint()
        end,
        desc = "Set Breakpoint",
      },
      {
        "<leader>dE",
        function()
          require("dap-breakpoints.api").edit_property()
        end,
        desc = "Edit Breakpoint Property",
      },
      {
        "<leader>dd",
        function()
          require("dap-breakpoints.api").clear_all_breakpoints()
        end,
        desc = "Clear All Breakpoints",
      },
      {
        "[<M-d>",
        function()
          require("dap-breakpoints.api").go_to_previous()
        end,
        desc = "Go to Previous Breakpoint",
      },
      {
        "]<M-d>",
        function()
          require("dap-breakpoints.api").go_to_next()
        end,
        desc = "Go to Next Breakpoint",
      },
    },
  },
  {
    "igorlfs/nvim-dap-view",
    enabled = false,
    -- let the plugin lazy load itself
    lazy = false,
    ---@module 'dap-view'
    ---@type dapview.Config
    opts = {},
    keys = {
      {
        "<leader>dv",
        function()
          require("dap-view").toggle()
        end,
        desc = "Toggle DAP View",
      },
    },
  },
}

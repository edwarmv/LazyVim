local user_preferences = require("user_preferences")

return {
  {
    "mrjones2014/smart-splits.nvim",
    opts = {
      cursor_follows_swapped_bufs = true,
    },
    keys = {
      {
        "<C-h>",
        function()
          require("smart-splits").move_cursor_left()
        end,
        desc = "Move Cursor Left",
      },
      {
        "<C-j>",
        function()
          require("smart-splits").move_cursor_down()
        end,
        desc = "Move Cursor Down",
      },
      {
        "<C-k>",
        function()
          require("smart-splits").move_cursor_up()
        end,
        desc = "Move Cursor Up",
      },
      {
        "<C-l>",
        function()
          require("smart-splits").move_cursor_right()
        end,
        desc = "Move Cursor Right",
      },
      {
        "<leader><leader>h",
        function()
          require("smart-splits").swap_buf_left()
        end,
        desc = "Swap Buf Left",
      },
      {
        "<leader><leader>j",
        function()
          require("smart-splits").swap_buf_down()
        end,
        desc = "Swap Buf Down",
      },
      {
        "<leader><leader>k",
        function()
          require("smart-splits").swap_buf_up()
        end,
        desc = "Swap Buf Up",
      },
      {
        "<leader><leader>l",
        function()
          require("smart-splits").swap_buf_right()
        end,
        desc = "Swap Buf Right",
      },
    },
  },
  {
    {
      "stevearc/aerial.nvim",
      optional = true,
      keys = {
        {
          "gss",
          function()
            require("aerial").snacks_picker()
          end,
          desc = "Aerial Snacks Picker",
        },
      },
    },
    {
      "nvim-lualine/lualine.nvim",
      optional = true,
      opts = function(_, opts)
        table.insert(opts.extensions, "aerial")
        opts.options.disabled_filetypes.winbar =
          vim.list_extend(opts.options.disabled_filetypes.winbar or {}, { "aerial" })
      end,
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      delay = function(ctx)
        return ctx.plugin and 0 or vim.o.timeoutlen / 2
      end,
    },
    keys = {
      {
        "z<space>",
        function()
          require("which-key").show({ keys = "z", loop = true })
        end,
        desc = "z Hydra Mode (which-key)",
      },
    },
  },
  {
    "haya14busa/vim-asterisk",
    keys = {
      { mode = { "n", "x" }, "z#", "<Plug>(asterisk-z#)" },
      { mode = { "n", "x" }, "z*", "<Plug>(asterisk-z*)" },
    },
  },
  {
    "folke/flash.nvim",
    keys = {
      { "S", mode = { "n", "o", "x" }, false },
      {
        "gs",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "<m-.>",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({ continue = true })
        end,
        desc = "Flash - Continue last search",
      },
      {
        "<leader>k",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({
            search = { forward = false, wrap = false, mode = "search", max_length = 0 },
            label = { after = { 0, 0 } },
            pattern = "^\\s*\\zs\\S",
          })
        end,
        desc = "Jump to a line",
      },
      {
        "<leader>j",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({
            search = { forward = true, wrap = false, mode = "search", max_length = 0 },
            label = { after = { 0, 0 } },
            pattern = "^\\s*\\zs\\S",
          })
        end,
        desc = "Jump to a line",
      },
    },
  },
  {
    {
      "folke/snacks.nvim",
      opts = function(_, opts)
        local icons = vim.deepcopy(LazyVim.config.icons.kinds)
        local function deduplicate_lsp(lsp_method)
          return {
            finder = function(opts, ctx)
              ctx.picker.seen_lsp = {}
              -- Call the original built-in snacks LSP finder method
              return require("snacks.picker.source.lsp")[lsp_method](opts, ctx)
            end,
            transform = function(item, ctx)
              local seen = ctx.picker.seen_lsp
              if not seen then
                return item
              end

              -- Create a unique key based on file path, line, and column position
              local id = string.format("%s:%s:%s", item.file, item.pos[1], item.pos[2])

              if seen[id] then
                return false -- Returning false filters out/drops the duplicate item
              end

              seen[id] = true
              return item
            end,
          }
        end

        local my_opts = {
          dashboard = {
            preset = {
              header = false,
            },
          },
          indent = {
            indent = {
              char = "▏",
            },
            scope = {
              char = "▏",
            },
          },
          picker = {
            sources = {
              lsp_declarations = {
                include_current = true,
              },
              lsp_definitions = {
                include_current = true,
              },
              lsp_implementations = {
                include_current = true,
              },
              lsp_incoming_calls = {
                include_current = true,
              },
              lsp_outgoing_calls = {
                include_current = true,
              },
              lsp_references = deduplicate_lsp("references"),
              lsp_type_definitions = {
                include_current = true,
              },
            },
            formatters = {
              file = {
                filename_first = true, -- display filename before the file path
              },
            },
            win = {
              input = {
                keys = {
                  ["<a-s>"] = { "flash", mode = { "n", "i" } },
                  ["s"] = { "flash" },
                },
              },
            },
            icons = {
              kinds = icons,
            },
            actions = {
              flash = function(picker)
                require("flash").jump({
                  pattern = "^",
                  label = { after = { 0, 0 } },
                  search = {
                    mode = "search",
                    exclude = {
                      function(win)
                        return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                      end,
                    },
                  },
                  action = function(match)
                    local idx = picker.list:row2idx(match.pos[1])
                    picker.list:_move(idx, true, true)
                  end,
                })
              end,
            },
          },
          lazygit = {
            config = {
              os = {
                edit = '[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote-send "<CMD>q<CR>" && nvim --server "$NVIM" --remote {{filename}})',
                editAtLine = '[ -z "$NVIM" ] && (nvim +{{line}} -- {{filename}}) || (nvim --server "$NVIM" --remote-send "<CMD>q<CR>" &&  nvim --server "$NVIM" --remote {{filename}} && nvim --server "$NVIM" --remote-send ":{{line}}<CR>")',
                editAtLineAndWait = "nvim +{{line}} {{filename}}",
                openDirInEditor = '[ -z "$NVIM" ] && (nvim -- {{dir}}) || (nvim --server "$NVIM" --remote-send "<CMD>q<CR>" && nvim --server "$NVIM" --remote {{dir}})',
              },
              promptToReturnFromSubprocess = false,
            },
          },
          styles = {
            lazygit = {
              keys = {
                { "Q", "hide", mode = { "t", "n" } },
              },
              wo = {
                winhighlight = "NormalFloat:Normal",
              },
            },
            terminal = {
              wo = {
                winhighlight = "NormalFloat:Normal",
              },
              keys = {
                gf = false,
              },
            },
            notification = {
              wo = {
                winblend = 0,
                wrap = true,
              },
            },
          },
        }

        return vim.tbl_deep_extend("force", opts or {}, my_opts)
      end,
      keys = {
        {
          "<leader>fe",
          function()
            Snacks.explorer({ cwd = LazyVim.root() })
          end,
          desc = "Explorer Snacks (root dir)",
        },
        {
          "<leader>fE",
          function()
            Snacks.explorer()
          end,
          desc = "Explorer Snacks (cwd)",
        },
        { "<leader>e", false },
        { "<leader>E", false },
        { "<leader><space>", false },
        {
          "g<c-t>",
          function()
            require("snacks_tab_picker").tabs_picker()
          end,
        },
      },
    },
    {
      "nvim-lualine/lualine.nvim",
      optional = true,
      opts = function(_, opts)
        opts.options.disabled_filetypes.winbar = vim.list_extend(opts.options.disabled_filetypes.winbar or {}, {
          "snacks_layout_box",
          "snacks_dashboard",
          "snacks_terminal",
        })
      end,
    },
  },
  {
    "TKasperczyk/snacks-gallery.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {},
    keys = {
      {
        "<leader><leader>g",
        function()
          require("snacks-gallery").open()
        end,
        desc = "Gallery",
      },
    },
  },
  {
    "2kabhishek/seeker.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = { "Seeker" },
    keys = {
      { "<leader><leader>ff", ":Seeker files<CR>", desc = "Seek Files" },
      { "<leader><leader>fg", ":Seeker git_files<CR>", desc = "Seek Git Files" },
      { "<leader><leader>sg", ":Seeker grep<CR>", desc = "Seek Grep" },
      { "<leader><leader>sw", ":Seeker grep_word<CR>", desc = "Seek Grep Word" },
    },
    opts = {}, -- Required unless you call seeker.setup() manually, add your configs here
  },
  {
    "s1n7ax/nvim-window-picker",
    name = "window-picker",
    opts = {
      hint = "floating-letter",
      show_prompt = false,
      filter_rules = {
        bo = {
          filetype = {},
          buftype = {},
        },
      },
    },
    keys = {
      {
        "gW",
        function()
          local _, picked_window_id = pcall(require("window-picker").pick_window)
          local cur_winid = vim.fn.win_getid()
          if picked_window_id and picked_window_id ~= cur_winid then
            vim.api.nvim_set_current_win(picked_window_id)
          end
        end,
        desc = "Pick a window",
      },
    },
  },
  {
    {
      "nvim-neo-tree/neo-tree.nvim",
      opts = {
        hijack_netrw_behavior = "disabled",
        popup_border_style = "", -- use winborder option
        auto_clean_after_session_restore = true,
        close_if_last_window = true,
        window = {
          mappings = {
            ["<C-s>"] = "split_with_window_picker",
            ["<C-v>"] = "vsplit_with_window_picker",
            ["<C-t>"] = "open_tabnew",
            ["<leader>y"] = "copy_selector",
            ["/"] = false,
            ["z"] = false,
            ["s"] = {
              "quick_jump",
              config = {
                on_jump = nil,
                jump_labels = "jfkdlsahgnuvrbytmiceoxwpqz",
              },
            },
            ["S"] = {
              "quick_jump",
              config = {
                on_jump = "open_or_toggle",
                jump_labels = "jfkdlsahgnuvrbytmiceoxwpqz",
              },
            },
            ["t"] = false,
          },
        },
        filesystem = {
          scan_mode = "deep",
          filtered_items = {
            visible = true,
          },
          follow_current_file = { enabled = true },
          hijack_netrw_behavior = "open_current",
        },
        default_component_configs = {
          indent = { padding = 0 },
          name = {
            highlight_opened_files = true,
          },
          file_size = { enabled = false },
          type = { enabled = false },
          last_modified = { enabled = false },
        },
        commands = {
          copy_selector = function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local filename = node.name

            require("copy_path").copy_path(filename, filepath)
          end,
        },
        event_handlers = {
          {
            event = "neo_tree_buffer_enter",
            handler = function()
              vim.opt_local.foldcolumn = "0"
              vim.opt_local.foldmethod = "manual"
            end,
          },
        },
      },
      keys = {
        { "<leader>fe", false },
        { "<leader>fE", false },
        {
          "<leader>e",
          function()
            require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
          end,
          desc = "Explorer NeoTree (Root Dir)",
        },
        {
          "<leader>E",
          function()
            require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
          end,
          desc = "Explorer NeoTree (cwd)",
        },
      },
    },
    {
      "nvim-lualine/lualine.nvim",
      optional = true,
      opts = function(_, opts)
        table.insert(opts.extensions, "neo-tree")
        opts.options.disabled_filetypes.winbar = vim.list_extend(opts.options.disabled_filetypes.winbar or {}, {
          "neo-tree",
        })
      end,
    },
  },
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = {
      "mini.icons",
    },
    opts = {
      view_options = {
        show_hidden = true,
      },
      lsp_file_methods = {
        enabled = true,
      },
      keymaps = {
        ["<C-v>"] = { "actions.select", opts = { vertical = true } },
        ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-h>"] = false,
        ["<C-t>"] = { "actions.select", opts = { tab = true } },
      },
    },
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Open parent directory in Oil" },
    },
  },
  {
    "andymass/vim-matchup",
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "" }
      vim.g.matchup_matchparen_deferred = true
    end,
  },
  {
    "gbprod/substitute.nvim",
    opts = {},
    keys = {
      {
        "cx",
        function()
          require("substitute.exchange").operator()
        end,
      },
      {
        "cxx",
        function()
          require("substitute.exchange").line()
        end,
      },
      {
        "X",
        function()
          require("substitute.exchange").visual()
        end,
        mode = "x",
      },
      {
        "cxc",
        function()
          require("substitute.exchange").cancel()
        end,
      },
    },
  },
  {
    "jake-stewart/multicursor.nvim",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      local set = vim.keymap.set

      -- Add a cursor for all matches of cursor word/selection in the document.
      set({ "n", "x" }, "<leader><leader>A", mc.matchAllAddCursors)

      -- Add or skip cursor above/below the main cursor.
      set({ "n", "x" }, "<m-up>", function()
        mc.lineAddCursor(-1)
      end)
      set({ "n", "x" }, "<m-down>", function()
        mc.lineAddCursor(1)
      end)
      set({ "n", "x" }, "<m-s-up>", function()
        mc.lineSkipCursor(-1)
      end)
      set({ "n", "x" }, "<m-s-down>", function()
        mc.lineSkipCursor(1)
      end)

      -- Add or skip adding a new cursor by matching word/selection
      set({ "n", "x" }, "<c-n>", function()
        mc.matchAddCursor(1)
      end)
      set({ "n", "x" }, "<c-s-n>", function()
        mc.matchSkipCursor(1)
      end)
      set({ "n", "x" }, "<c-p>", function()
        mc.matchAddCursor(-1)
      end)
      set({ "n", "x" }, "<c-s-p>", function()
        mc.matchSkipCursor(-1)
      end)

      -- Add and remove cursors with control + left click.
      set("n", "<c-leftmouse>", mc.handleMouse)
      set("n", "<c-leftdrag>", mc.handleMouseDrag)
      set("n", "<c-leftrelease>", mc.handleMouseRelease)

      -- Disable and enable cursors.
      -- set({ "n", "x" }, "<c-q>", mc.toggleCursor)

      -- Mappings defined in a keymap layer only apply when there are
      -- multiple cursors. This lets you have overlapping mappings.
      mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one.
        layerSet({ "n", "x" }, "<left>", mc.prevCursor)
        layerSet({ "n", "x" }, "<right>", mc.nextCursor)
        -- Align cursor columns.
        layerSet("n", "<leader><leader>a", mc.alignCursors)

        -- Delete the main cursor.
        -- layerSet({ "n", "x" }, "<leader>mx", mc.deleteCursor)

        -- Enable and clear cursors using escape.
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)

      -- Customize how cursors look.
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { link = "Cursor" })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn" })
      hl(0, "MultiCursorMatchPreview", { link = "Search" })
      hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end,
  },
  {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    opts = function()
      local routers = require("gitlinker.routers")
      return {
        router = {
          browse = {
            ["^gitlab%.ekupd%.com"] = routers.gitlab_browse,
          },
          blame = {
            ["^gitlab%.ekupd%.com"] = routers.gitlab_blame,
          },
        },
      }
    end,
    keys = {
      { "<leader>gy", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Yank git link" },
      { "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open git link" },
    },
  },
  {
    "rhysd/conflict-marker.vim",
    enabled = false,
    event = "VeryLazy",
  },
  {
    "spacedentist/resolve.nvim",
    enabled = false,
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
  {
    "dlyongemallo/diffview.nvim",
    opts = function()
      local actions = require("diffview.actions")

      local preferred_width = math.max(1, math.floor(vim.o.columns / 4))
      local function toggle_file_panel_width()
        local view = require("diffview.lib").get_current_view()
        if not (view and view.panel) then
          return
        end

        local panel = view.panel
        local width = panel:get_config().width == "auto" and preferred_width or "auto"

        panel._base_config_producer = panel._base_config_producer or panel.config_producer
        local base_config_producer = panel._base_config_producer

        if vim.is_callable(base_config_producer) then
          panel.config_producer = function()
            local conf = base_config_producer()
            if type(conf) ~= "table" then
              conf = {}
            end
            conf.width = width
            return conf
          end
        elseif type(base_config_producer) == "table" then
          panel.config_producer = vim.tbl_deep_extend("force", vim.deepcopy(base_config_producer), { width = width })
        else
          panel.config_producer = { width = width }
        end

        panel:render()
        panel:redraw()
        panel:resize()
      end

      return {
        enhanced_diff_hl = true,
        diffopt = { algorithm = "histogram" },
        persist_selections = { enabled = true },
        clean_up_buffers = true,
        file_panel = {
          show_branch_name = true,
          always_show_sections = true,
          win_config = function()
            return {
              width = preferred_width,
              win_opts = {
                signcolumn = "no",
              },
            }
          end,
        },
        keymaps = {
          view = {
            ["<leader>co"] = false,
            ["<leader>ct"] = false,
            ["<leader>cb"] = false,
            ["<leader>ca"] = false,
            ["<leader>cO"] = false,
            ["<leader>cT"] = false,
            ["<leader>cB"] = false,
            ["<leader>cA"] = false,
            {
              "n",
              "<localleader>co",
              actions.conflict_choose("ours"),
              { desc = "Choose the OURS version of a conflict" },
            },
            {
              "n",
              "<localleader>ct",
              actions.conflict_choose("theirs"),
              { desc = "Choose the THEIRS version of a conflict" },
            },
            {
              "n",
              "<localleader>cb",
              actions.conflict_choose("base"),
              { desc = "Choose the BASE version of a conflict" },
            },
            {
              "n",
              "<localleader>ca",
              actions.conflict_choose("all"),
              { desc = "Choose all the versions of a conflict" },
            },
            {
              "n",
              "<localleader>cO",
              actions.conflict_choose_all("ours"),
              { desc = "Choose the OURS version of a conflict for the whole file" },
            },
            {
              "n",
              "<localleader>cT",
              actions.conflict_choose_all("theirs"),
              { desc = "Choose the THEIRS version of a conflict for the whole file" },
            },
            {
              "n",
              "<localleader>cB",
              actions.conflict_choose_all("base"),
              { desc = "Choose the BASE version of a conflict for the whole file" },
            },
            {
              "n",
              "<localleader>cA",
              actions.conflict_choose_all("all"),
              { desc = "Choose all the versions of a conflict for the whole file" },
            },
          },
          file_panel = {
            ["<space>"] = false,
            {
              "n",
              "e",
              toggle_file_panel_width,
              { desc = "Toggle file panel width" },
            },
            {
              { "n", "x" },
              "<S-space>",
              actions.toggle_select_entry,
              { desc = "Toggle file selection for multi-file operations" },
            },
            ["<leader>cO"] = false,
            ["<leader>cT"] = false,
            ["<leader>cB"] = false,
            ["<leader>cA"] = false,
            {
              "n",
              "<localleader>cO",
              actions.conflict_choose_all("ours"),
              { desc = "Choose the OURS version of a conflict for the whole file" },
            },
            {
              "n",
              "<localleader>cT",
              actions.conflict_choose_all("theirs"),
              { desc = "Choose the THEIRS version of a conflict for the whole file" },
            },
            {
              "n",
              "<localleader>cB",
              actions.conflict_choose_all("base"),
              { desc = "Choose the BASE version of a conflict for the whole file" },
            },
            {
              "n",
              "<localleader>cA",
              actions.conflict_choose_all("all"),
              { desc = "Choose all the versions of a conflict for the whole file" },
            },
          },
        },
        view = {
          merge_tool = {
            disable_diagnostics = false,
          },
        },
      }
    end,
    cmd = {
      "DiffviewOpen",
      "DiffviewFileHistory",
      "DiffviewClose",
      "DiffviewToggle",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewLog",
    },
    keys = {
      {
        "<leader><leader>dO",
        function()
          local diffview = require("diffview")
          local all = vim.fn.systemlist({ "git", "rev-parse", "--symbolic", "--branches", "--tags", "--remotes" })
          local original_base = "Original base"
          table.insert(all, 1, original_base)
          vim.ui.select(all, {
            prompt = "Select branch",
          }, function(choice)
            if choice == nil then
              return
            elseif choice == original_base then
              choice = nil
            end
            diffview.open({ choice })
          end)
        end,
        desc = "Diffview - Open Against a Branch",
      },
      { "<leader><leader>do", "<cmd>DiffviewOpen<cr>", desc = "Diffview - Open" },
      { "<leader><leader>dH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview - File History" },
      {
        mode = { "n", "x" },
        "<leader><leader>dh",
        ":DiffviewFileHistory %<cr>",
        desc = "Diffview - File History Current File",
      },
      { "<leader><leader>dr", "<cmd>DiffviewRefresh<cr>", desc = "Diffview - Refresh" },
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      -- "esmuellert/codediff.nvim",
      "diffview.nvim",
      "folke/snacks.nvim",
    },
    opts = {
      signs = {
        hunk = { user_preferences.icons.foldclose, user_preferences.icons.foldopen },
        item = { user_preferences.icons.foldclose, user_preferences.icons.foldopen },
        section = { user_preferences.icons.foldclose, user_preferences.icons.foldopen },
      },
      graph_style = "kitty",
      mappings = {
        status = {
          ["1"] = false,
          ["2"] = false,
          ["3"] = false,
          ["4"] = false,
          ["<localleader>1"] = "Depth1",
          ["<localleader>2"] = "Depth2",
          ["<localleader>3"] = "Depth3",
          ["<localleader>4"] = "Depth4",
        },
      },
    },
    cmd = { "Neogit", "NeogitResetState", "NeogitLog", "NeogitCommit" },
    keys = {
      {
        "<leader>gN",
        function()
          require("neogit").open()
        end,
        desc = "Neogit (cwd)",
      },
      {
        "<leader>gn",
        function()
          if vim.b.gitsigns_status_dict then
            require("neogit").open({ cwd = vim.b.gitsigns_status_dict.root })
          else
            require("neogit").open()
          end
        end,
        desc = "Neogit (Root Dir)",
      },
      {
        mode = { "n", "x" },
        "<leader>g<C-l>",
        ":NeogitLog<CR>",
        desc = "Neogit Log",
      },
      {
        "<leader>g<C-n>",
        function()
          local cwd = vim.fn.getcwd(-1, -1)
          local root = vim.system({ "git", "rev-parse", "--show-toplevel" }, { cwd = cwd }):wait()

          if root.code ~= 0 then
            vim.notify("Unable to find git root for current cwd", vim.log.levels.ERROR)
            return
          end

          local repo_root = vim.trim(root.stdout)
          local submodule_result = vim
            .system({ "git", "submodule", "status", "--recursive" }, { cwd = repo_root })
            :wait()

          if submodule_result.code ~= 0 then
            vim.notify("Failed to read git submodules", vim.log.levels.ERROR)
            return
          end

          local submodules = {}
          for _, line in ipairs(vim.split(submodule_result.stdout, "\n", { trimempty = true })) do
            local path = vim.trim(line):match("^%S+%s+([^%s]+)")
            if path then
              table.insert(submodules, path)
            end
          end

          if vim.tbl_isempty(submodules) then
            vim.notify("No git submodules found", vim.log.levels.INFO)
            return
          end

          table.sort(submodules)

          vim.ui.select(submodules, { prompt = "Select submodule" }, function(choice)
            if choice == nil then
              return
            end

            require("neogit").open({ cwd = vim.fs.joinpath(repo_root, choice) })
          end)
        end,
        desc = "Neogit (Select Submodule)",
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signs_staged = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      preview_config = {
        row = 1,
        col = 0,
      },
      numhl = true,
      attach_to_untracked = true,
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
        end

        -- stylua: ignore start
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghP", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map("n", "<leader>ghc", function()
          require("git_utils").change_base(buffer, true)
        end,  "Change Base Global" )
        map("n", "<leader>ghC", function()
          require("git_utils").change_base(buffer)
        end,  "Change Base" )
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  {
    "tpope/vim-fugitive",
    init = function()
      vim.g.fugitive_legacy_commands = false
    end,
  },
  {
    "esmuellert/codediff.nvim",
    enabled = false,
    cmd = { "CodeDiff", "VscodeDiff" },
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
    keys = {
      {
        "<leader><leader>d",
        ":VscodeDiff",
        desc = "CodeDiff",
      },
    },
  },
  {
    "michaelb/sniprun",
    branch = "master",
    build = "sh install.sh",
    opts = function()
      local opts = {
        selected_interpreters = { "Lua_nvim", "JS_TS_bun" },
        display = {
          "VirtualLine",
        },
        snipruncolors = {
          SniprunVirtualTextOk = {
            bg = Snacks.util.color("DiagnosticVirtualTextOk", "bg"),
            fg = Snacks.util.color("DiagnosticVirtualTextOk"),
          },
          SniprunVirtualTextErr = {
            bg = Snacks.util.color("DiagnosticVirtualLinesError", "bg"),
            fg = Snacks.util.color("DiagnosticVirtualLinesError"),
          },
        },
      }

      return opts
    end,
    keys = {
      { mode = { "n", "v" }, "gRr", "<Plug>SnipRun", desc = "SnipRun" },
      { "gR<cr>", "<CMD>%SnipRun<CR>", desc = "SnipRun - Entiry File" },
      { "gRc", "<CMD>SnipClose<CR>", desc = "SnipClose" },
    },
  },
  {
    "HawkinsT/pathfinder.nvim",
    opts = {
      remap_default_keys = false,
    },
    keys = {
      {
        "gf",
        function()
          require("pathfinder").gf()
        end,
        desc = "Go to file",
        remap = true,
      },
      {
        "gF",
        function()
          require("pathfinder").gF()
        end,
        desc = "Go to file (line)",
        remap = true,
      },
      {
        "gx",
        function()
          require("pathfinder").gx()
        end,
        desc = "Open with system app",
        remap = true,
      },
    },
  },
  {
    -- Avoid opening files in specific windows
    "stevearc/stickybuf.nvim",
    opts = {},
  },
  {
    "ThePrimeagen/harpoon",
    opts = function(_, opts)
      local harpoon_extensions = require("harpoon.extensions")
      local harpoon = require("harpoon")
      harpoon:extend(harpoon_extensions.builtins.highlight_current_file())
      harpoon:extend(harpoon_extensions.builtins.navigate_with_number())

      return opts
    end,
    keys = function()
      local keys = {
        {
          "<leader>H",
          function()
            require("harpoon"):list():add()
            local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
            vim.notify(string.format("Added %s to Harpoon", filename))
          end,
          desc = "Harpoon File",
        },
        {
          "<leader>h",
          function()
            local harpoon = require("harpoon")
            harpoon.ui:toggle_quick_menu(harpoon:list(), {
              border = vim.o.winborder,
            })
          end,
          desc = "Harpoon Quick Menu",
        },
      }

      for i = 1, 9 do
        table.insert(keys, {
          "<leader>" .. i,
          function()
            require("harpoon"):list():select(i)
          end,
          desc = "Harpoon to File " .. i,
        })
      end
      return keys
    end,
  },
  {
    {
      "folke/trouble.nvim",
      opts = function(_, opts)
        local icons = vim.deepcopy(LazyVim.config.icons.kinds)

        local my_opts = {
          icons = {
            kinds = icons,
          },
        }

        return vim.tbl_deep_extend("force", opts or {}, my_opts)
      end,
    },
    {
      "nvim-lualine/lualine.nvim",
      optional = true,
      opts = function(_, opts)
        table.insert(opts.extensions, "trouble")
        opts.options.disabled_filetypes.winbar = vim.list_extend(opts.options.disabled_filetypes.winbar or {}, {
          "trouble",
        })
      end,
    },
  },
  { "nvim-mini/mini.align", opts = {} },
  {
    -- Better indentexpr
    "hrsh7th/nvim-anydent",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          require("anydent").attach()
        end,
      })
    end,
  },
}

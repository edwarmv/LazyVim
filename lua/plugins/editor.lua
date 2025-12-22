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
        "<localleader><localleader>h",
        function()
          require("smart-splits").swap_buf_left()
        end,
        desc = "Swap Buf Left",
      },
      {
        "<localleader><localleader>j",
        function()
          require("smart-splits").swap_buf_down()
        end,
        desc = "Swap Buf Down",
      },
      {
        "<localleader><localleader>k",
        function()
          require("smart-splits").swap_buf_up()
        end,
        desc = "Swap Buf Up",
      },
      {
        "<localleader><localleader>l",
        function()
          require("smart-splits").swap_buf_right()
        end,
        desc = "Swap Buf Right",
      },
    },
  },
  {
    "folke/which-key.nvim",
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
        "Z",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "<c-.>",
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
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        enabled = false,
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
      statuscolumn = {
        enabled = false,
        folds = {
          open = true,
          git_hl = true,
        },
      },
      picker = {
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
        },
      },
      explorer = {},
    },
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
    },
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
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      use_popups_for_input = false,
      window = {
        mappings = {
          ["<C-s>"] = "split_with_window_picker",
          ["<C-v>"] = "vsplit_with_window_picker",
          ["<C-t>"] = "open_tabnew",
          ["z"] = false,
        },
      },
      filesystem = {
        scan_mode = "deep",
        filtered_items = {
          visible = true,
        },
      },
      default_component_configs = {
        name = {
          highlight_opened_files = true,
        },
        file_size = { enabled = false },
        type = { enabled = false },
        last_modified = { enabled = false },
      },
      event_handlers = {
        {
          event = "neo_tree_window_after_open",
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
    "stevearc/oil.nvim",
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "OilActionsPost",
        callback = function(event)
          if event.data.actions[1].type == "move" then
            Snacks.rename.on_rename_file(event.data.actions[1].src_url, event.data.actions[1].dest_url)
          end
        end,
      })
    end,
    dependencies = {
      "mini.icons",
    },
    opts = {
      view_options = {
        show_hidden = true,
      },
    },
    keys = {
      { "<localleader>e", "<cmd>Oil<cr>", desc = "Oil" },
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
      set({ "n", "x" }, "<localleader><localleader>A", mc.matchAllAddCursors)

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
        layerSet("n", "<localleader><localleader>a", mc.alignCursors)

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
    event = "VeryLazy",
  },
  {
    "sindrets/diffview.nvim",
    opts = {},
    cmd = { "DiffviewOpen" },
    keys = {
      {
        "<leader>gdO",
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
        desc = "Diffview - Open",
      },
      { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Diffview - Open" },
      { "<leader>gdq", "<cmd>DiffviewClose<cr>", desc = "Diffview - Close" },
      { "<leader>gdH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview - File History" },
      { "<leader>gdh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview - File History Current File" },
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim",
      "lewis6991/gitsigns.nvim",
    },
    opts = {
      disable_signs = false,
      signs = {
        hunk = { "▶", "▼" },
        item = { "▶", "▼" },
        section = { "▶", "▼" },
      },
      graph_style = "unicode",
    },
    keys = {
      {
        "<leader>gN",
        function()
          require("neogit").open()
        end,
        desc = "[Neogit] - Open",
      },
      {
        "<leader>gn",
        function()
          if vim.b.gitsigns_status_dict then
            require("neogit").open({ cwd = vim.b.gitsigns_status_dict.root })
          end
        end,
        desc = "[Neogit] - Open Relative",
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
      numhl = true,
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
          local root = LazyVim.root({ buf = buffer, normalize = true })

          local result = vim
            .system({ "git", "rev-parse", "--symbolic", "--branches", "--tags", "--remotes" }, { cwd = root })
            :wait()

          if result.code ~= 0 then
            vim.notify("Git command failed: " .. result.stderr, vim.log.levels.ERROR)
            return
          end

          local all = vim.split(result.stdout, "\n", { trimempty = true })
          local original_base = "Original base"
          table.insert(all, 1, original_base)

          vim.ui.select(all, { prompt = "Select branch" }, function(choice)
            if choice == nil then
              return
            elseif choice == original_base then
              choice = nil
            end
            require("gitsigns").change_base(choice, true)
          end)
        end,  "Change Base" )
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  {
    "esmuellert/vscode-diff.nvim",
    cmd = { "CodeDiff" },
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
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
      { mode = { "n", "v" }, "<leader>rr", "<Plug>SnipRun", desc = "SnipRun" },
      { "<leader>r<cr>", "<CMD>%SnipRun<CR>", desc = "SnipRun - Entiry File" },
      { "<leader>rc", "<CMD>SnipClose<CR>", desc = "SnipClose" },
    },
  },
  {
    "HawkinsT/pathfinder.nvim",
    opts = function()
      local function goto_line_column(window, line_arg, col_arg)
        local target_line = math.max(1, line_arg)
        local target_col = (col_arg and col_arg > 0) and (col_arg - 1) or 0
        pcall(vim.api.nvim_win_set_cursor, window, { target_line, target_col })
      end

      return {
        open_mode = function(escaped_target_path, line_arg, col_arg)
          if vim.bo.buftype == "terminal" then
            vim.cmd("ToggleTerm")
          end
          local open_cmd = "edit"
          vim.cmd(open_cmd .. " " .. escaped_target_path)
          -- For commands like :edit, set cursor on the current window (0).
          if line_arg then
            goto_line_column(0, line_arg, col_arg)
          end
        end,
        remap_default_keys = false,
      }
    end,
    keys = {
      {
        "gf",
        function()
          require("pathfinder").gf()
        end,
      },
      {
        "gF",
        function()
          require("pathfinder").gF()
        end,
      },
      {
        "gx",
        function()
          require("pathfinder").gx()
        end,
      },
    },
  },
  {
    "ThePrimeagen/harpoon",
    keys = function()
      local keys = {
        {
          "gH",
          function()
            require("harpoon"):list():add()
          end,
          desc = "Harpoon File",
        },
        {
          "gh",
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
}

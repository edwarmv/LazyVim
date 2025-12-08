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
      opts.options.disabled_filetypes.winbar = {
        "",
        "dap-view",
        "dap-repl",
        "snacks_layout_box",
        "qf",
        "neo-tree",
        "toggleterm",
        "snacks_dashboard",
        "snacks_terminal",
        "aerial",
      }
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
    "Bekaboo/dropbar.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    event = "VeryLazy",
    opts = {
      bar = {
        enable = function(buf, win, _)
          buf = vim._resolve_bufnr(buf)
          if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
            return false
          end

          if
            not vim.api.nvim_buf_is_valid(buf)
            or not vim.api.nvim_win_is_valid(win)
            or vim.fn.win_gettype(win) ~= ""
            or vim.wo[win].winbar ~= ""
            or vim.tbl_contains({
              "oil",
              "help",
              "toggleterm",
            }, vim.bo[buf].ft)
          then
            return false
          end

          local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
          if stat and stat.size > 1024 * 1024 then
            return false
          end

          return vim.bo[buf].ft == "markdown"
            or pcall(vim.treesitter.get_parser, buf)
            or not vim.tbl_isempty(vim.lsp.get_clients({
              bufnr = buf,
              method = "textDocument/documentSymbol",
            }))
        end,
      },
      sources = {
        path = {
          -- disable preview because of No Alternate File error
          -- <c-6> does not work
          preview = false,
        },
      },
      menu = {
        keymaps = {
          ["H"] = function()
            local root = require("dropbar.utils").menu.get_current():root()
            if not root then
              return
            end
            root:close()

            local dropbar =
              require("dropbar.utils.bar").get({ buf = vim.api.nvim_win_get_buf(root.prev_win), win = root.prev_win })
            if not dropbar then
              root:toggle()
              return
            end

            local current_idx
            for idx, component in ipairs(dropbar.components) do
              if component.menu == root then
                current_idx = idx
                break
              end
            end

            if current_idx == nil or current_idx == 0 then
              root:toggle()
              return
            end

            vim.defer_fn(function()
              dropbar:pick(current_idx - 1)
            end, 100)
          end,

          ["L"] = function()
            local root = require("dropbar.utils").menu.get_current():root()
            if not root then
              return
            end
            root:close()

            local dropbar =
              require("dropbar.utils.bar").get({ buf = vim.api.nvim_win_get_buf(root.prev_win), win = root.prev_win })
            if not dropbar then
              dropbar = require("dropbar.utils").bar.get_current()
              if not dropbar then
                root:toggle()
                return
              end
            end

            local current_idx
            for idx, component in ipairs(dropbar.components) do
              if component.menu == root then
                current_idx = idx
                break
              end
            end

            if current_idx == nil or current_idx == #dropbar.components then
              root:toggle()
              return
            end

            vim.defer_fn(function()
              dropbar:pick(current_idx + 1)
            end, 100)
          end,
        },
      },
      icons = {
        kinds = {
          symbols = {
            Text = " ",
            Method = " ",
            Function = " ",
            Constructor = " ",
            Field = " ",
            Variable = " ",
            Class = " ",
            Interface = " ",
            Module = " ",
            Property = " ",
            Unit = " ",
            Value = " ",
            Enum = " ",
            Keyword = " ",
            Snippet = " ",
            Color = " ",
            File = " ",
            Reference = " ",
            Folder = " ",
            EnumMember = " ",
            Constant = " ",
            Struct = " ",
            Event = " ",
            Operator = " ",
            TypeParameter = " ",
          },
        },
      },
    },
    keys = {
      {
        "<leader>;",
        function()
          require("dropbar.api").pick()
        end,
        desc = "Dropbar - Pick",
      },
      {
        "[;",
        function()
          require("dropbar.api").goto_context_start()
        end,
        desc = "Go to start of current context",
      },
      {
        "];",
        function()
          require("dropbar.api").select_next_context()
        end,
        desc = "Select next context",
      },
    },
  },
  {
    "rebelot/heirline.nvim",
    enabled = false,
    dependencies = {
      "zeioth/heirline-components.nvim",
      opts = function()
        return {
          icons = {
            BreadcrumbSeparator = "⟩",
            DiagnosticError = LazyVim.config.icons.diagnostics.Error,
            DiagnosticHint = LazyVim.config.icons.diagnostics.Hint,
            DiagnosticInfo = LazyVim.config.icons.diagnostics.Info,
            DiagnosticWarn = LazyVim.config.icons.diagnostics.Warn,
            GitAdd = LazyVim.config.icons.git.added,
            GitChange = LazyVim.config.icons.git.modified,
            GitDelete = LazyVim.config.icons.git.removed,
          },
        }
      end,
    },
    event = "UiEnter",
    opts = function()
      local lib = require("heirline-components.all")

      -- this is the default function used to retrieve buffers
      local get_bufs = function()
        return vim.tbl_filter(function(bufnr)
          return vim.api.nvim_get_option_value("buflisted", { buf = bufnr })
        end, vim.api.nvim_list_bufs())
      end

      -- initialize the buflist cache
      local buflist_cache = {}

      -- setup an autocmd that updates the buflist_cache every time that buffers are added/removed
      vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufAdd", "BufDelete" }, {
        callback = function()
          vim.schedule(function()
            local buffers = get_bufs()
            for i, v in ipairs(buffers) do
              buflist_cache[i] = v
            end
            for i = #buffers + 1, #buflist_cache do
              buflist_cache[i] = nil
            end

            -- check how many buffers we have and set showtabline accordingly
            if #buflist_cache > 1 then
              vim.o.showtabline = 2 -- always
            elseif vim.o.showtabline ~= 1 then -- don't reset the option if it's already at default value
              vim.o.showtabline = 1 -- only when #tabpages > 1
            end
          end)
        end,
      })

      local heirline = require("heirline-components.core.heirline")
      local core_utils = require("heirline-components.core.utils")
      local provider = require("heirline-components.core.provider")
      local hl = require("heirline-components.core.hl")
      local buf_utils = require("heirline-components.buffer")
      local utils = require("heirline-components.utils")
      local get_icon = utils.get_icon
      heirline.make_buflist = function(component)
        local overflow_hl = hl.get_attributes("buffer_overflow", true)
        return require("heirline.utils").make_buflist(
          core_utils.surround(
            "tab",
            function(self)
              return {
                main = heirline.tab_type(self) .. "_bg",
                left = "tabline_bg",
                right = "tabline_bg",
              }
            end,
            { -- bufferlist
              init = function(self)
                self.tab_type = heirline.tab_type(self)
              end,
              on_click = { -- add clickable component to each buffer
                callback = function(_, minwid)
                  vim.api.nvim_win_set_buf(0, minwid)
                end,
                minwid = function(self)
                  return self.bufnr
                end,
                name = "heirline_tabline_buffer_callback",
              },
              { -- add buffer picker functionality to each buffer
                condition = function(self)
                  return self._show_picker
                end,
                update = false,
                init = function(self)
                  if not (self.label and self._picker_labels[self.label]) then
                    local bufname = provider.filename()(self)
                    local label = bufname:sub(1, 1)
                    local i = 2
                    while label ~= " " and self._picker_labels[label] do
                      if i > #bufname then
                        break
                      end
                      label = bufname:sub(i, i)
                      i = i + 1
                    end
                    self._picker_labels[label] = self.bufnr
                    self.label = label
                  end
                end,
                provider = function(self)
                  return provider.str({
                    str = self.label,
                    padding = { left = 1, right = 1 },
                  })
                end,
                hl = hl.get_attributes("buffer_picker"),
              },
              component, -- create buffer component
            },
            function(self)
              return buf_utils.is_valid(self.bufnr)
            end -- disable surrounding
          ),
          { provider = get_icon("ArrowLeft") .. " ", hl = overflow_hl },
          { provider = get_icon("ArrowRight") .. " ", hl = overflow_hl },
          function()
            return buflist_cache
          end, -- use the default function to get the buffer list
          false -- disable internal caching
        )
      end

      require("heirline-components.core.provider").git_branch = function(opts)
        return function(self)
          local value = core_utils.stylize(vim.b[self and self.bufnr or 0].gitsigns_head or "", opts)
          local max_width = vim.o.columns * 1 / 5
          value = string.len(value) <= max_width and value or string.sub(value, 1, max_width) .. "…"

          return value
        end
      end

      local _root_dir = LazyVim.lualine.root_dir({ icon = "󱉭" })
      local root_dir = {
        provider = function()
          return " " .. _root_dir[1]() .. " "
        end,
        condition = _root_dir.cond,
      }

      local noice_command = {
        provider = function()
          return "   " .. require("noice").api.status.command.get()
        end,
        condition = function()
          return package.loaded["noice"] and require("noice").api.status.command.has()
        end,
        hl = function()
          return { fg = Snacks.util.color("Statement") }
        end,
      }

      local noice_mode = {
        provider = function()
          return "   " .. require("noice").api.status.mode.get()
        end,
        condition = function()
          return package.loaded["noice"] and require("noice").api.status.mode.has()
        end,
        hl = function()
          return { fg = Snacks.util.color("Constant") }
        end,
      }

      local git_branch = function()
        local branch = lib.component.git_branch()
        -- print(vim.inspect(branch[1]))

        return branch
      end

      return {
        opts = {
          disable_winbar_cb = function(args) -- We do this to avoid showing it on the greeter.
            local is_disabled = not require("heirline-components.buffer").is_valid(args.buf)
              or lib.condition.buffer_matches({
                buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
                filetype = { "NvimTree", "neo%-tree", "dashboard", "Outline", "aerial" },
              }, args.buf)
            return is_disabled
          end,
        },
        tabline = { -- UI upper bar
          lib.component.tabline_conditional_padding(),
          lib.component.tabline_buffers({
            hl = function(self)
              local tab_type = self.tab_type
              if self._show_picker and self.tab_type ~= "buffer_active" then
                tab_type = "buffer_visible"
              end

              local _hl = hl.get_attributes(tab_type)

              local has_diagnostics = vim.tbl_contains(
                vim.diagnostic.count(self.bufnr or 0, { severity = vim.diagnostic.severity.ERROR }),
                function(v)
                  return v > 0
                end,
                { predicate = true }
              )

              if has_diagnostics then
                _hl.fg = Snacks.util.color("DiagnosticError")
              end

              return _hl
            end,
          }),
          lib.component.fill({ hl = { bg = "tabline_bg" } }),
          lib.component.tabline_tabpages(),
        },
        winbar = { -- UI breadcrumbs bar
          init = function(self)
            self.bufnr = vim.api.nvim_get_current_buf()
          end,
          fallthrough = false,
          {
            lib.component.file_info({
              filename = {},
              filetype = false,
              hl = function(args)
                local _hl = hl.get_attributes("file_info")

                local has_diagnostics = vim.tbl_contains(
                  vim.diagnostic.count(args.bufnr or 0, { severity = vim.diagnostic.severity.ERROR }),
                  function(v)
                    return v > 0
                  end,
                  { predicate = true }
                )

                if has_diagnostics then
                  _hl.fg = Snacks.util.color("DiagnosticError")
                end

                return _hl
              end,
            }),
            lib.component.fill(),
            root_dir,
          },
        },
        statuscolumn = { -- UI left column
          init = function(self)
            self.bufnr = vim.api.nvim_get_current_buf()
          end,
          lib.component.foldcolumn(),
          lib.component.numbercolumn(),
          lib.component.signcolumn(),
        } or nil,
        statusline = { -- UI statusbar
          hl = { fg = "fg", bg = "bg" },
          lib.component.mode(),
          lib.component.git_branch(),
          lib.component.git_diff(),
          lib.component.diagnostics(),
          lib.component.breadcrumbs(),
          lib.component.fill(),
          noice_command,
          noice_mode,
          lib.component.file_info({ surround = { separator = "right" } }),
          lib.component.compiler_state(),
          lib.component.virtual_env(),
          lib.component.nav(),
          lib.component.mode({ surround = { separator = "right" } }),
        },
      }
    end,
    config = function(_, opts)
      local heirline = require("heirline")
      local heirline_components = require("heirline-components.all")

      -- Setup
      heirline_components.init.subscribe_to_events()
      heirline.load_colors(heirline_components.hl.get_colors())
      heirline.setup(opts)
    end,
  },
  {
    "akinsho/bufferline.nvim",
    enabled = true,
    opts = {
      options = {
        always_show_bufferline = true,
        separator_style = "slant",
        show_close_icon = false,
        show_buffer_close_icons = false,
        truncate_names = false,
        sort_by = "insert_at_end",
      },
    },
  },
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        hover = {
          enabled = false,
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
    },
  },
  {
    "ntpeters/vim-better-whitespace",
    event = "VimEnter",
    init = function()
      vim.g.better_whitespace_enabled = 1
      vim.g.better_whitespace_operator = "<localleader>s"
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
}

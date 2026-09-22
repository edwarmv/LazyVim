---@diagnostic disable: missing-fields
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local my_opts = vim.tbl_deep_extend("force", opts or {}, {
        indent = {
          enable = true,
        },
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          local parsers = require("nvim-treesitter.parsers")
          parsers.ghostty = {
            install_info = {
              url = "https://github.com/bezhermoso/tree-sitter-ghostty",
              branch = "main",
              queries = "queries/ghostty",
            },
          }
          parsers.tmux = {
            install_info = {
              url = "https://github.com/Freed-Wu/tree-sitter-tmux",
              branch = "master",
              generate = true,
              generate_from_json = false,
            },
          }
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          local available_langs = require("nvim-treesitter").get_available()
          local is_available = vim.tbl_contains(available_langs, lang)
          if is_available and lang then
            local installed_langs = require("nvim-treesitter").get_installed()
            local installed = vim.tbl_contains(installed_langs, lang)
            if not installed then
              require("nvim-treesitter").install(lang):await(function()
                vim.notify("Installed " .. lang .. " parser", vim.log.levels.INFO, { title = "nvim-treesitter" })

                ---@param feat string
                ---@param query string
                local function enabled(feat, query)
                  local f = my_opts[feat] or {} ---@type lazyvim.TSFeat
                  return f.enable ~= false
                    and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang))
                    and LazyVim.treesitter.have_query(lang, query)
                end

                -- highlighting
                if enabled("highlight", "highlights") then
                  pcall(vim.treesitter.start, ev.buf)
                end

                -- indents
                if enabled("indent", "indents") then
                  LazyVim.set_default("indentexpr", "v:lua.LazyVim.treesitter.indentexpr()")
                end

                -- folds
                if enabled("folds", "folds") then
                  if LazyVim.set_default("foldmethod", "expr") then
                    LazyVim.set_default("foldexpr", "v:lua.LazyVim.treesitter.foldexpr()")
                  end
                end
              end)
            end
          end
        end,
      })

      return my_opts
    end,
  },
}

return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      dim_inactive = true,
      lualine_bold = true,
      on_highlights = function(hl, c)
        local util = require("tokyonight.util")

        hl.ExtraWhitespace = {
          fg = c.red,
          bg = util.blend(c.red, 0.15, c.bg),
        }
        hl.ResolveOursMarker = { link = "DiffAdd" }
        hl.ResolveTheirsMarker = { link = "DiffChange" }
        hl.ResolveSeparatorMarker = { link = "NonText" }
        hl.ResolveAncestorMarker = { link = "DiffText" }
        hl.ResolveOursSection = { link = "DiffAdd" }
        hl.ResolveTheirsSection = { link = "DiffChange" }
        hl.ResolveAncestorSection = { link = "DiffText" }
        hl.CursorLineFold = { link = "CursorLine" }
        hl.CursorLineNr = { link = "CursorLine" }
        hl.CursorLineSign = { link = "CursorLine" }
        hl.LualineModifiedFilename = { fg = c.green, italic = true, bold = true }
        hl.LualineFilename = { fg = c.fg, bold = true }
        if vim.o.background == "light" then
          hl.FlashLabel.fg = c.bg
        end
      end,
    },
  },
  {
    "rose-pine/neovim",
    lazy = true,
    name = "rose-pine",
    opts = {
      enable = {
        -- disable terminal colors to avoid issues with reporting light/dark mode
        terminal = false,
      },
      dim_inactive_windows = true,
      highlight_groups = {
        ExtraWhitespace = { fg = "love", bg = "love", blend = 20 },
        ["@markup.link.label"] = {},
        LuasnipInsertNodePassive = { bg = "gold", blend = 20 },
        LuasnipChoiceNodePassive = { bg = "gold", blend = 20 },
        BlinkCmpDocBorder = { fg = "highlight_high", bg = "highlight_low" },
        PmenuSel = { fg = "none", bg = "overlay" },
        BufferLineTabSelected = { fg = "text", bg = "base" },
        ConflictMarkerBegin = { bg = "gold", blend = 40 },
        ConflictMarkerOurs = { bg = "gold", blend = 20 },
        ConflictMarkerTheirs = { bg = "foam", blend = 20 },
        ConflictMarkerEnd = { bg = "foam", blend = 40 },
        ConflictMarkerCommonAncestorsHunk = { bg = "love", blend = 40 },
        ResolveOursMarker = { link = "DiffAdd" },
        ResolveTheirsMarker = { link = "DiffChange" },
        ResolveSeparatorMarker = { link = "NonText" },
        ResolveAncestorMarker = { link = "DiffText" },
        ResolveOursSection = { link = "DiffAdd" },
        ResolveTheirsSection = { link = "DiffChange" },
        ResolveAncestorSection = { link = "DiffText" },
        LualineModifiedFilename = { fg = "pine", italic = true, bold = true },
        LualineFilename = { fg = "text", bold = true },
        SidekickDiffAdd = { link = "DiffAdd" },
        SidekickDiffContext = { bg = "surface" },
        CursorLineFold = { link = "CursorLine" },
        CursorLineNr = { link = "CursorLine" },
        CursorLineSign = { link = "CursorLine" },
        PmenuSbar = { bg = "overlay" },
      },
    },
  },
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = function()
      local U = require("catppuccin.utils.colors")

      return {
        term_colors = true,
        dim_inactive = {
          enabled = true,
        },
        auto_integrations = true,
        lsp_styles = {
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        custom_highlights = function(C)
          return {
            ExtraWhitespace = { fg = C.red, bg = U.darken(C.red, 0.15, C.base) },
            ResolveOursMarker = { link = "DiffAdd" },
            ResolveTheirsMarker = { link = "DiffChange" },
            ResolveSeparatorMarker = { link = "NonText" },
            ResolveAncestorMarker = { link = "DiffText" },
            ResolveOursSection = { link = "DiffAdd" },
            ResolveTheirsSection = { link = "DiffChange" },
            ResolveAncestorSection = { link = "DiffText" },
            LualineModifiedFilename = { fg = C.green, italic = true, bold = true },
            LualineFilename = { fg = C.text, bold = true },
            CursorLineFold = { link = "CursorLine" },
            CursorLineNr = { link = "CursorLine" },
            CursorLineSign = { link = "CursorLine" },
          }
        end,
        highlight_overrides = {
          latte = function(C)
            return {
              CursorLine = { bg = U.lighten(C.surface0, 0.5, C.base) },
            }
          end,
        },
      }
    end,
  },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = true,
    opts = {
      variant = "auto",
      transparent = true,
    },
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    opts = {
      overrides = function(colors)
        local color = require("kanagawa.lib.color")
        local theme = colors.theme

        return {
          ExtraWhitespace = { bg = color(theme.ui.bg):blend(theme.term[2], 0.15):to_hex(), fg = theme.term[2] },
          ["@markup.link"] = { link = "Special" },
          htmlLink = { link = "Special" },
          FlashBackdrop = { fg = theme.syn.comment },
          IlluminatedWordText = { link = "LspReferenceText" },
          IlluminatedWordRead = { link = "LspReferenceRead" },
          IlluminatedWordWrite = { link = "LspReferenceWrite" },
        }
      end,
    },
  },
  {
    "loctvl842/monokai-pro.nvim",
    lazy = true,
    opts = {
      day_night = {
        enable = true,
        day_filter = "light",
      },
    },
  },
  {
    "olimorris/onedarkpro.nvim",
    lazy = true,
    opts = {},
  },
  {
    "sainnhe/gruvbox-material",
    lazy = true,
    init = function()
      vim.g.gruvbox_material_float_style = "blend"
      vim.g.gruvbox_material_disable_terminal_colors = true
      vim.g.gruvbox_material_dim_inactive_windows = true
      vim.g.gruvbox_material_enable_italic = true
      vim.g.gruvbox_material_enable_bold = true
      vim.g.gruvbox_material_inlay_hints_background = "dimmed"
      vim.g.gruvbox_material_diagnostic_line_highlight = true
      vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
      vim.g.gruvbox_material_ui_contrast = "high"

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("custom_highlights_gruvboxmaterial", {}),
        pattern = "gruvbox-material",
        callback = function()
          local config = vim.fn["gruvbox_material#get_configuration"]()
          local palette =
            vim.fn["gruvbox_material#get_palette"](config.background, config.foreground, config.colors_override)
          local set_hl = vim.fn["gruvbox_material#highlight"]

          set_hl("NonText", palette.grey0, palette.none)
          set_hl("ExtraWhitespace", palette.red, palette.bg_visual_red)
          set_hl("LuasnipInsertNodePassive", palette.none, palette.bg3)
          set_hl("LuasnipChoiceNodePassive", palette.none, palette.bg3)
          set_hl("LualineModifiedFilename", palette.green, palette.none, "italic,bold")
          set_hl("LualineFilename", palette.fg0, palette.none, "bold")
          set_hl("PmenuSbar", palette.none, palette.bg5)
          vim.api.nvim_set_hl(0, "ResolveOursMarker", { link = "DiffAdd" })
          vim.api.nvim_set_hl(0, "ResolveTheirsMarker", { link = "DiffChange" })
          vim.api.nvim_set_hl(0, "ResolveSeparatorMarker", { link = "NonText" })
          vim.api.nvim_set_hl(0, "ResolveAncestorMarker", { link = "DiffText" })
          vim.api.nvim_set_hl(0, "ResolveOursSection", { link = "DiffAdd" })
          vim.api.nvim_set_hl(0, "ResolveTheirsSection", { link = "DiffChange" })
          vim.api.nvim_set_hl(0, "ResolveAncestorSection", { link = "DiffText" })
          vim.api.nvim_set_hl(0, "CursorLineFold", { link = "CursorLine" })
          vim.api.nvim_set_hl(0, "CursorLineNr", { link = "CursorLine" })
          vim.api.nvim_set_hl(0, "CursorLineSign", { link = "CursorLine" })
        end,
      })
    end,
  },
  {
    "sainnhe/everforest",
    lazy = true,
    init = function()
      vim.g.everforest_float_style = "blend"
      vim.g.everforest_disable_terminal_colors = true
      vim.g.everforest_dim_inactive_windows = true
      vim.g.everforest_enable_italic = true
      vim.g.everforest_inlay_hints_background = "dimmed"
      vim.g.everforest_diagnostic_line_highlight = true
      vim.g.everforest_diagnostic_virtual_text = "colored"
      vim.g.gruvbox_material_ui_contrast = "high"

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("custom_highlights_everforest", {}),
        pattern = "everforest",
        callback = function()
          local config = vim.fn["everforest#get_configuration"]()
          local palette = vim.fn["everforest#get_palette"](config.background, config.colors_override)
          local set_hl = vim.fn["everforest#highlight"]

          set_hl("NonText", palette.grey0, palette.none)
          set_hl("LuasnipInsertNodePassive", palette.none, palette.bg_visual)
          set_hl("LuasnipChoiceNodePassive", palette.none, palette.bg_visual)
          set_hl("ExtraWhitespace", palette.red, palette.bg_red)
          set_hl("LualineModifiedFilename", palette.green, palette.none, "italic,bold")
          set_hl("LualineFilename", palette.fg, palette.none, "bold")
          vim.api.nvim_set_hl(0, "CursorLineFold", { link = "CursorLine" })
          vim.api.nvim_set_hl(0, "CursorLineNr", { link = "CursorLine" })
          vim.api.nvim_set_hl(0, "CursorLineSign", { link = "CursorLine" })
        end,
      })
    end,
  },
  {
    "marko-cerovac/material.nvim",
    lazy = true,
  },
  {
    "everviolet/nvim",
    name = "evergarden",
    lazy = true,
    opts = {
      theme = {
        variant = "fall", -- 'winter'|'fall'|'spring'|'summer'
        accent = "green",
      },
      editor = {
        transparent_background = false,
        sign = { color = "none" },
        float = {
          color = "mantle",
          solid_border = false,
        },
        completion = {
          color = "surface0",
        },
      },
    },
  },
  {
    "webhooked/kanso.nvim",
    lazy = true,
  },
  {
    "marekh19/meowsoot.nvim",
    lazy = true,
    opts = {},
  },
}

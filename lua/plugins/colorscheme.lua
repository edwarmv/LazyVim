return {
  -- { "xiyaowong/transparent.nvim" },
  {
    "rose-pine/neovim",
    lazy = true,
    name = "rose-pine",
    opts = {
      styles = {
        transparency = false,
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
      },
      groups = {
        git_change = "gold",
      },
    },
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
    build = ":KanagawaCompile",
    opts = {
      compile = true,
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
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_float_style = "dim"

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("custom_highlights_gruvboxmaterial", {}),
        pattern = "gruvbox-material",
        callback = function()
          local config = vim.fn["gruvbox_material#get_configuration"]()
          local palette =
            vim.fn["gruvbox_material#get_palette"](config.background, config.foreground, config.colors_override)
          local set_hl = vim.fn["gruvbox_material#highlight"]

          set_hl("ExtraWhitespace", palette.red, palette.bg_visual_red)

          vim.api.nvim_set_hl(0, "ResolveOursMarker", { link = "DiffAdd" })
          vim.api.nvim_set_hl(0, "ResolveTheirsMarker", { link = "DiffChange" })
          vim.api.nvim_set_hl(0, "ResolveSeparatorMarker", { link = "NonText" })
          vim.api.nvim_set_hl(0, "ResolveAncestorMarker", { link = "DiffText" })
          vim.api.nvim_set_hl(0, "ResolveOursSection", { link = "DiffAdd" })
          vim.api.nvim_set_hl(0, "ResolveTheirsSection", { link = "DiffChange" })
          vim.api.nvim_set_hl(0, "ResolveAncestorSection", { link = "DiffText" })
        end,
      })
    end,
  },
  {
    "sainnhe/everforest",
    lazy = true,
    init = function()
      vim.g.everforest_enable_italic = true
      vim.g.everforest_dim_inactive_windows = true
      vim.g.everforest_better_performance = true
      vim.g.everforest_disable_terminal_colors = 1

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("custom_highlights_everforest", {}),
        pattern = "everforest",
        callback = function()
          local config = vim.fn["everforest#get_configuration"]()
          local palette = vim.fn["everforest#get_palette"](config.background, config.colors_override)
          local set_hl = vim.fn["everforest#highlight"]

          set_hl("LuasnipInsertNodePassive", palette.none, palette.bg_visual)
          set_hl("LuasnipChoiceNodePassive", palette.none, palette.bg_visual)
          set_hl("ExtraWhitespace", palette.red, palette.bg_red)
        end,
      })
    end,
  },
  {
    "zenbones-theme/zenbones.nvim",
    lazy = true,
    init = function()
      -- vim.g.zenbones_transparent_background = true
    end,
    dependencies = "rktjmp/lush.nvim",
  },
  {
    "marko-cerovac/material.nvim",
    lazy = true,
  },
}

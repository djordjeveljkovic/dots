return {
  -- Rosé Pine (https://github.com/rose-pine/neovim)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      variant = "auto", -- follows vim.o.background; main | moon | dawn
      dark_variant = "main",
      dim_inactive_windows = false,
      extend = {},
    },
  },

  -- make Rosé Pine the LazyVim colorscheme
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "rose-pine" },
  },

  -- stop loading the bundled colorschemes
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", name = "catppuccin", enabled = false },
}

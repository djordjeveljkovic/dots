return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        -- Alacritty does not support inline images, so omit the ASCII image fallback.
        sections = {
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },
}

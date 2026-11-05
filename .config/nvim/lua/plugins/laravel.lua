return {
  -- Blade tree-sitter highlighting (*.blade.php is auto-detected as ft=blade)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "blade" } },
  },

  -- Laravel: artisan / routes / tinker / make pickers, completion, gf, code actions
  {
    "adalessa/laravel.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
    },
    ft = { "php", "blade" },
    event = { "BufRead composer.json" },
    -- NOTE: use <leader>L (capital) to avoid LazyVim's <leader>l = Lazy
    keys = {
      {
        "<leader>Ll",
        function()
          Laravel.pickers.laravel()
        end,
        desc = "Laravel: Picker",
      },
      {
        "<leader>La",
        function()
          Laravel.pickers.artisan()
        end,
        desc = "Laravel: Artisan",
      },
      {
        "<leader>Lr",
        function()
          Laravel.pickers.routes()
        end,
        desc = "Laravel: Routes",
      },
      {
        "<leader>Lm",
        function()
          Laravel.pickers.make()
        end,
        desc = "Laravel: Make",
      },
      {
        "<leader>Lc",
        function()
          Laravel.pickers.commands()
        end,
        desc = "Laravel: Commands",
      },
      {
        "<leader>Lo",
        function()
          Laravel.pickers.resources()
        end,
        desc = "Laravel: Resources",
      },
      {
        "<leader>Lu",
        function()
          Laravel.commands.run("hub")
        end,
        desc = "Laravel: Artisan Hub",
      },
      {
        "<leader>Lt",
        function()
          Laravel.commands.run("actions")
        end,
        desc = "Laravel: Code Actions",
      },
      {
        "<leader>Lh",
        function()
          Laravel.run("artisan docs")
        end,
        desc = "Laravel: Docs",
      },
    },
    opts = {
      features = { pickers = { provider = "snacks" } }, -- LazyVim ships snacks.picker
    },
  },
}

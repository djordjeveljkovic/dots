return {
  {
    "nvim-pack/nvim-spectre",
    lazy = true,
    cmd = { "Spectre" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = function()
      return {
        highlight = {
          search = "SpectreSearch",
          replace = "SpectreReplace",
        },
        mapping = {
          ["send_to_qf"] = {
            map = "<C-q>",
            cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
            desc = "send all items to quickfix",
          },
        },
      }
    end,
    config = function(_, opts)
      require("spectre").setup(opts)
    end,
  },
}


-- Autocommand for the 'oil' filetype
local function setup_oil_autocmd()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "oil",
    callback = function()
      vim.opt_local.colorcolumn = ""
    end,
  })
end

return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional dependencies
    opts = {
      use_default_keymaps = false,
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-\\>"] = "actions.select_vsplit",
        ["<C-enter>"] = "actions.select_split", -- Navigate left
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
      },
      view_options = {
        show_hidden = true,
      },
    },
    config = function(_, opts)
      require("oil").setup(opts)
      setup_oil_autocmd() -- Set up the autocmd for 'oil' filetype
    end,
  },
}


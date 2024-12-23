return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        cond = vim.fn.executable("cmake") == 1,
      },
      "catppuccin/nvim", -- Add Catppuccin as a dependency
    },
    opts = function()
      local actions = require("telescope.actions")
      local theme = require("catppuccin.palettes").get_palette("frappe")

      -- Apply Catppuccin Frappe highlights
      vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = theme.surface0, fg = theme.text })
      vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = theme.surface0, fg = theme.surface2 })
      vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = theme.surface1, fg = theme.text })
      vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = theme.surface1, fg = theme.surface2 })
      vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = theme.surface0, fg = theme.text })
      vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = theme.surface0, fg = theme.surface2 })
      vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = theme.surface0, fg = theme.text })
      vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = theme.surface0, fg = theme.surface2 })

      return {
        defaults = {
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-x>"] = actions.delete_buffer,
            },
          },
          file_ignore_patterns = {
            "node_modules",
            "yarn.lock",
            ".git",
            ".sl",
            "_build",
            ".next",
          },
          hidden = true,
        },
      }
    end,
    config = function(_, opts)
      require("telescope").setup(opts)

      -- Load extensions
      pcall(require("telescope").load_extension, "fzf")
    end,
  },
}


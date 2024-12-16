return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      local lualine = require("lualine")
      local harpoon = require("harpoon.mark")
      local catppuccin = require("catppuccin.palettes").get_palette("frappe")

      -- Utility function to truncate branch name
      local function truncate_branch_name(branch)
        return branch or ""
      end

      -- Harpoon component for displaying current mark and total marks
      local function harpoon_component()
        local total_marks = harpoon.get_length()
        if total_marks == 0 then
          return ""
        end

        local mark_idx = harpoon.get_current_index()
        local current_mark = mark_idx and tostring(mark_idx) or "—"

        return string.format("󱡅 %s/%d", current_mark, total_marks)
      end

      -- Custom Catppuccin colors for Lualine
      local custom_catppuccin_theme = {
        normal = {
          a = { fg = catppuccin.text, bg = catppuccin.mauve, gui = "bold" },
          b = { fg = catppuccin.text, bg = catppuccin.surface0 },
          c = { fg = catppuccin.text, bg = catppuccin.surface1 },
        },
        insert = {
          a = { fg = catppuccin.text, bg = catppuccin.green, gui = "bold" },
        },
        visual = {
          a = { fg = catppuccin.text, bg = catppuccin.peach, gui = "bold" },
        },
        replace = {
          a = { fg = catppuccin.text, bg = catppuccin.red, gui = "bold" },
        },
        command = {
          a = { fg = catppuccin.text, bg = catppuccin.blue, gui = "bold" },
        },
        inactive = {
          a = { fg = catppuccin.overlay1, bg = catppuccin.surface1 },
          b = { fg = catppuccin.overlay1, bg = catppuccin.surface1 },
          c = { fg = catppuccin.overlay1, bg = catppuccin.surface0 },
        },
      }

      -- Lualine configuration
      lualine.setup({
        options = {
          theme = custom_catppuccin_theme,
          globalstatus = true,
          component_separators = { left = ":|:", right = ":|:" },
          section_separators = { left = "█", right = "█" },
        },
        sections = {
          lualine_b = {
            { "branch", icon = "", fmt = truncate_branch_name },
            harpoon_component,
            "diff",
            "diagnostics",
          },
          lualine_c = {
            { "filename", path = 1 },
          },
          lualine_x = {
            "filetype",
          },
        },
      })
    end,
  },
}


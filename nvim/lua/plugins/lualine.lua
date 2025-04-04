return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      local lualine = require("lualine")
      local harpoon = require("harpoon.mark")

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

      -- Lualine configuration
      lualine.setup({
        options = {
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


return {
  {
    "gelguy/wilder.nvim",
    keys = { ":", "/", "?" },
    dependencies = {
      "catppuccin/nvim", -- Catppuccin for consistent theme usage
    },
    config = function()
      local wilder = require("wilder")
      local frappe = require("catppuccin.palettes").get_palette("frappe")

      -- Create highlight groups using Catppuccin Frappe palette
      local function create_highlight_group(name, color)
        return wilder.make_hl(name, {
          { a = 1 },
          { a = 1 },
          { foreground = color },
        })
      end

      local text_highlight = create_highlight_group("WilderText", frappe.text)
      local mauve_highlight = create_highlight_group("WilderMauve", frappe.mauve)

      -- Wilder setup
      wilder.setup({ modes = { ":", "/", "?" } })

      -- Enable fuzzy matching for commands and searches
      wilder.set_option("pipeline", {
        wilder.branch(
          wilder.cmdline_pipeline({ fuzzy = 1 }),
          wilder.vim_search_pipeline({ fuzzy = 1 })
        ),
      })

      -- Popup menu renderer with Catppuccin Frappe colors
      wilder.set_option(
        "renderer",
        wilder.popupmenu_renderer(
          wilder.popupmenu_border_theme({
            highlighter = wilder.basic_highlighter(),
            highlights = {
              default = text_highlight,
              border = mauve_highlight,
              accent = mauve_highlight,
            },
            pumblend = 5,
            min_width = "100%",
            min_height = "25%",
            max_height = "25%",
            border = "rounded",
            left = { " ", wilder.popupmenu_devicons() },
            right = { " ", wilder.popupmenu_scrollbar() },
          })
        )
      )
    end,
  },
}


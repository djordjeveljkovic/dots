return {
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      local notify = require("notify")

      -- List of messages to filter out
      local filtered_messages = { "No information available" }

      -- Override vim.notify to filter messages and set custom options
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.notify = function(message, level, opts)
        -- Check if the message is in the filtered list
        for _, msg in ipairs(filtered_messages) do
          if message == msg then
            return
          end
        end

        -- Merge custom options with provided options
        local merged_opts = vim.tbl_extend("force", {
          on_open = function(win)
            local buf = vim.api.nvim_win_get_buf(win)
            vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
          end,
        }, opts or {})

        return notify(message, level, merged_opts)
      end

      -- Function to define highlight groups
      local function set_highlight(group, color)
        vim.cmd(string.format("highlight %s guifg=%s", group, color))
      end

      -- Catppuccin Frappe Colors
      local frappe_colors = {
        error = "#e64553", -- Red
        warn = "#f4a261",  -- Yellow
        info = "#6ccef3",  -- Blue
        border = "#303446", -- Gray
      }

      -- Set custom highlight groups for notifications using Frappe colors
      local highlights = {
        { group = "NotifyERRORBorder", color = frappe_colors.error },
        { group = "NotifyERRORIcon", color = frappe_colors.error },
        { group = "NotifyERRORTitle", color = frappe_colors.error },
        { group = "NotifyINFOBorder", color = frappe_colors.info },
        { group = "NotifyINFOIcon", color = frappe_colors.info },
        { group = "NotifyINFOTitle", color = frappe_colors.info },
        { group = "NotifyWARNBorder", color = frappe_colors.warn },
        { group = "NotifyWARNIcon", color = frappe_colors.warn },
        { group = "NotifyWARNTitle", color = frappe_colors.warn },
        { group = "NotifyDEBUGBorder", color = frappe_colors.border },
        { group = "NotifyDEBUGIcon", color = frappe_colors.border },
        { group = "NotifyDEBUGTitle", color = frappe_colors.border },
      }

      for _, highlight in ipairs(highlights) do
        set_highlight(highlight.group, highlight.color)
      end
    end,
  },
}


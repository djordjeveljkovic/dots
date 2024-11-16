return {
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      local notify = require("notify")

      local filtered_message = { "No information available" }

      -- Override notify function to filter out messages
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.notify = function(message, level, opts)
        local merged_opts = vim.tbl_extend("force", {
          on_open = function(win)
            local buf = vim.api.nvim_win_get_buf(win)
            vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
          end,
        }, opts or {})

        for _, msg in ipairs(filtered_message) do
          if message == msg then
            return
          end
        end
        return notify(message, level, merged_opts)
      end

      -- Update colors to use catpuccino colors
      vim.cmd([[
        highlight NotifyERRORBorder guifg=#cc241d
        highlight NotifyERRORIcon guifg=#cc241d
        highlight NotifyERRORTitle guifg=#cc241d
        highlight NotifyINFOBorder guifg=#458588
        highlight NotifyINFOIcon guifg=#458588
        highlight NotifyINFOTitle guifg=#458588
        highlight NotifyWARNBorder guifg=#d79921
        highlight NotifyWARNIcon guifg=#d79921
        highlight NotifyWARNTitle guifg=#d79921
        " highlight NotifyERRORBorder guifg=#ed8796
        " highlight NotifyERRORIcon guifg=#ed8796
        " highlight NotifyERRORTitle  guifg=#ed8796
        " highlight NotifyINFOBorder guifg=#8aadf4
        " highlight NotifyINFOIcon guifg=#8aadf4
        " highlight NotifyINFOTitle guifg=#8aadf4
        " highlight NotifyWARNBorder guifg=#f5a97f
        " highlight NotifyWARNIcon guifg=#f5a97f
        " highlight NotifyWARNTitle guifg=#f5a97f
      ]])
    end,
  },
}

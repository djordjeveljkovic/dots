local tnoremap = require("config.keymaps.keymap_utils").tnoremap

-- Determine the operating system
local os_name = vim.loop.os_uname().sysname
local term_cmd

if os_name == "Windows_NT" then
    -- Use PowerShell on Windows
    term_cmd = "powershell"
else
    -- Use the default local shell on other platforms
    term_cmd = os.getenv("SHELL") or "/bin/bash"
end

-- Function to open the terminal
local function open_terminal()
    vim.cmd("split | term " .. term_cmd)
end
-- Exit terminal mode
tnoremap("<Esc>", [[<C-\><C-n>]])
tnoremap("<C-n>", [[<C-\><C-n>]])

-- Window navigation
tnoremap("<C-h>", [[<C-\><C-n><C-w>h]])
tnoremap("<C-j>", [[<C-\><C-n><C-w>j]])
tnoremap("<C-k>", [[<C-\><C-n><C-w>k]])
tnoremap("<C-l>", [[<C-\><C-n><C-w>l]])

-- Resize windows
tnoremap("<C-Up>", [[<C-\><C-n>:resize +2<CR>]])
tnoremap("<C-Down>", [[<C-\><C-n>:resize -2<CR>]])
tnoremap("<C-Left>", [[<C-\><C-n>:vertical resize -2<CR>]])
tnoremap("<C-Right>", [[<C-\><C-n>:vertical resize +2<CR>]])

-- Toggle terminal
vim.api.nvim_set_keymap("n", "<leader>t", "", { noremap = true, silent = true, callback = open_terminal })
tnoremap("<leader>t", [[<C-\><C-n>:q<CR>]])

-- Send commands
tnoremap("<F5>", [[<C-\><C-n>:!ls<CR>i]])
tnoremap("<F6>", [[<C-\><C-n>:!git status<CR>i]])

-- Reenable default <space> functionality to prevent input delay
tnoremap("<space>", "<space>")



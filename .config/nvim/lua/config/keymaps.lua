-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Keep system clipboard operations explicit so normal yanks stay local.
vim.keymap.set({ "n", "x" }, "uy", '"+y', { desc = "Yank to clipboard" })

-- paste from system clipboard register
vim.keymap.set({ "n", "x" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })

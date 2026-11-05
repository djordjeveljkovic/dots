-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Rosé Pine requires true color
vim.opt.termguicolors = true

-- Keep ordinary yanks in Vim's registers; use explicit mappings for the system clipboard.
vim.opt.clipboard = ""

-- Disable the tabline / bufferline top bar
vim.opt.showtabline = 0

-- LSP choices
vim.g.lazyvim_php_lsp = "phpactor" -- or "intelephense"
vim.g.lazyvim_ts_lsp = "vtsls"

-- LaTeX: only `tectonic` is installed (no latexmk / pdflatex)
vim.g.vimtex_compiler_method = "tectonic"

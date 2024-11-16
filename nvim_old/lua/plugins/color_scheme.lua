return {
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			require("gruvbox").setup({
				integrations = {
					cmp = true,
					gitsigns = true,
					harpoon = true,
					illuminate = true,
					indent_blankline = {
						enabled = false,
						scope_color = "sapphire",
						colored_indent_levels = false,
					},
					mason = true,
					native_lsp = { enabled = true },
					notify = true,
					nvimtree = true,
					neotree = true,
					symbols_outline = true,
					telescope = true,
					treesitter = true,
					treesitter_context = true,
					terminal_colors = true, -- add neovim terminal colors
					undercurl = true,
					underline = true,
					bold = true,
					italic = {
						strings = true,
						emphasis = true,
						comments = true,
						operators = false,
						folds = true,
					},
					strikethrough = true,
					invert_selection = false,
					invert_signs = false,
					invert_tabline = false,
					invert_intend_guides = false,
					inverse = true, -- invert background for search, diffs, statuslines and errors
					contrast = "", -- can be "hard", "soft" or empty string
					palette_overrides = {},
					overrides = {},
					dim_inactive = false,
					transparent_mode = false,
				},
			})

			vim.o.background = "dark"
			vim.cmd("colorscheme gruvbox")
		end,
	},
	-- {
	-- 	"catppuccin/nvim",
	-- 	config = function()
	-- 		require("catppuccin").setup({
	-- 			integrations = {
	-- 				cmp = true,
	-- 				gitsigns = true,
	-- 				harpoon = true,
	-- 				illuminate = true,
	-- 				indent_blankline = {
	-- 					enabled = false,
	-- 					scope_color = "sapphire",
	-- 					colored_indent_levels = false,
	-- 				},
	-- 				mason = true,
	-- 				native_lsp = { enabled = true },
	-- 				notify = true,
	-- 				nvimtree = true,
	-- 				neotree = true,
	-- 				symbols_outline = true,
	-- 				telescope = true,
	-- 				treesitter = true,
	-- 				treesitter_context = true,
	-- 			},
	-- 		})
	--
	-- 		-- vim.cmd.colorscheme("catppuccin-macchiato")
	--
	-- 		-- Hide all semantic highlights until upstream issues are resolved (https://github.com/catppuccin/nvim/issues/480)
	-- 		for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
	-- 			vim.api.nvim_set_hl(0, group, {})
	-- 		end
	-- 	end,
	-- },
}

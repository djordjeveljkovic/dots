-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local result = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})

	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ result, "WarningMsg" },
			{ "\nPress any key to exit...", "WarningMsg" },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
-- Prepend the runtime path with lazy.nvim
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
	{ import = "plugins" },
}, {
	change_detection = {
		enabled = true,
		notify = false,
	},
})

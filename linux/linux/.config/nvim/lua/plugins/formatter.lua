return {
    {
        "mhartington/formatter.nvim",
        event = { "BufWritePre", "BufReadPre" },
        config = function()
            local util = require "formatter.util"

            require("formatter").setup {
                logging = true,
                log_level = vim.log.levels.WARN,
                filetype = {
                    lua = {
                        require("formatter.filetypes.lua").stylua,
                    },
                    html = {
                        function()
                            return {
                                exe = "prettier",
                                args = {
                                    "--stdin-filepath",
                                    util.escape_path(util.get_current_buffer_file_path()),
                                    "--parser", "html"
                                },
                                stdin = true,
                            }
                        end,
                    },
                    htmlangular = {
                        function()
                            return {
                                exe = "prettier",
                                args = {
                                    "--stdin-filepath",
                                    util.escape_path(util.get_current_buffer_file_path()),
                                    "--parser", "angular",
                                },
                                stdin = true,
                            }
                        end,
                    },
                    css = {
                        function()
                            return {
                                exe = "prettier",
                                args = {
                                    "--stdin-filepath",
                                    util.escape_path(util.get_current_buffer_file_path()),
                                    "--parser", "css"
                                },
                                stdin = true,
                            }
                        end,
                    },
                    javascript = {
                        function()
                            return {
                                exe = "prettier",
                                args = {
                                    "--stdin-filepath",
                                    util.escape_path(util.get_current_buffer_file_path()),
                                    "--parser", "babel"
                                },
                                stdin = true,
                            }
                        end,
                    },
                    ["*"] = {
                        require("formatter.filetypes.any").remove_trailing_whitespace,
                    },
                },
            }

            -- Keymaps
            vim.keymap.set("n", "=<", "<cmd>Format<CR>", { desc = "Format file" })
            vim.keymap.set("v", "=<", "<cmd>Format<CR>", { desc = "Format selection" })
        end,
    }
}

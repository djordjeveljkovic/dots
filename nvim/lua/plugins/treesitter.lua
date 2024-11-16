return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })
    end,
    event = { "BufEnter" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects", -- Additional text objects for Treesitter
    },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "css",
        "gleam",
        "graphql",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "ocaml",
        "ocaml_interface",
        "prisma",
        "tsx",
        "typescript",
        "vim",
        -- "yaml", -- Disabled due to known issues
      },
      sync_install = false,
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
        disable = { "ocaml", "ocaml_interface" },
      },
      autopairs = {
        enable = true,
      },
      autotag = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<c-space>",
          node_incremental = "<c-space>",
          scope_incremental = "<c-s>",
          node_decremental = "<c-backspace>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- Whether to set jumps in the jumplist
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}


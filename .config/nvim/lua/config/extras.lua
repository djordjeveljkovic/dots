-- LazyVim extras registered as version-controlled import specs.
-- https://www.lazyvim.org/extras
return {
  -- languages
  { import = "lazyvim.plugins.extras.lang.php" },
  { import = "lazyvim.plugins.extras.lang.typescript" }, -- JS / Node / React / TS
  { import = "lazyvim.plugins.extras.lang.vue" }, -- pulls typescript itself
  { import = "lazyvim.plugins.extras.lang.python" }, -- pyright + ruff
  { import = "lazyvim.plugins.extras.lang.go" }, -- gopls
  { import = "lazyvim.plugins.extras.lang.rust" }, -- rustaceanvim

  -- documents
  { import = "lazyvim.plugins.extras.lang.tex" }, -- vimtex + texlab
  { import = "lazyvim.plugins.extras.lang.typst" }, -- tinymist + preview
  { import = "lazyvim.plugins.extras.lang.markdown" }, -- marksman + preview

  -- supporting languages / tools
  { import = "lazyvim.plugins.extras.lang.tailwind" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.yaml" },
  { import = "lazyvim.plugins.extras.lang.docker" },
  { import = "lazyvim.plugins.extras.lang.sql" },

  -- formatting / linting
  { import = "lazyvim.plugins.extras.formatting.prettier" },
  { import = "lazyvim.plugins.extras.linting.eslint" },

  -- debug + tests for every language above
  { import = "lazyvim.plugins.extras.dap.core" },
  { import = "lazyvim.plugins.extras.test.core" },

  -- coding
  { import = "lazyvim.plugins.extras.coding.mini-surround" },
}

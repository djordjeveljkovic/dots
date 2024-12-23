return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost" },
    cmd = { "LspInfo", "LspInstall", "LspUninstall", "Mason" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "nvimtools/none-ls.nvim",
      "folke/neodev.nvim",
      { "j-hui/fidget.nvim", tag = "legacy" },
    },
    config = function()
      local null_ls = require("null-ls")
      local map_lsp_keybinds = require("config.keymaps.general").map_lsp_keybinds

      -- Setup Mason
      require("mason").setup({ ui = { border = "rounded" } })

      -- Setup Mason-LSPConfig
      require("mason-lspconfig").setup({
        automatic_installation = { exclude = { "gleam" } },
      })

      require("biome").setup()
      -- Use Neodev for better Lua development
      require("neodev").setup()

      -- Diagnostics customization
      vim.diagnostic.config({
        float = { border = "rounded" },
      })

      -- Filter tsserver diagnostics
      local function filter_tsserver_diagnostics(_, result, ctx, config)
        local filtered_diagnostics = {}
        local messages_to_filter = {
          "This may be converted to an async function.",
          "'_Assertion' is declared but never used.",
          "'__Assertion' is declared but never used.",
          "The signature '(data: string): string' of 'atob' is deprecated.",
          "The signature '(data: string): string' of 'btoa' is deprecated.",
        }

        for _, diagnostic in ipairs(result.diagnostics) do
          local should_filter = false
          for _, message in ipairs(messages_to_filter) do
            if diagnostic.message == message then
              should_filter = true
              break
            end
          end
          if not should_filter then
            table.insert(filtered_diagnostics, diagnostic)
          end
        end

        result.diagnostics = filtered_diagnostics
        vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
      end

      -- Default LSP handlers
      local default_handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
        ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
      }

      -- nvim-cmp capabilities
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Function to handle LSP on_attach
      local function on_attach(client, buffer)
        map_lsp_keybinds(buffer)

        vim.api.nvim_buf_create_user_command(buffer, "Format", function()
          vim.lsp.buf.format({
            filter = function(format_client)
              return format_client.name ~= "tsserver" or not null_ls.is_registered("prettier")
            end,
          })
        end, { desc = "Format buffer with LSP" })
      end

      -- Configure LSP servers
      local servers = {
        bashls = {},
        cssls = {},
        gleam = {},
        graphql = {},
        html = {},
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enabled = false },
            },
          },
        },
        marksman = {},
        pyright = {},
        solidity = {},
        sqlls = {},
        tailwindcss = {},
        ts_ls = {
          settings = {
            experimental = { enableProjectDiagnostics = true },
          },
          handlers = {
            ["textDocument/publishDiagnostics"] = vim.lsp.with(filter_tsserver_diagnostics, {}),
          },
        },
        yamlls = {},
        gopls = {
          settings = {
            gopls = {
              usePlaceholders = true,
              analyses = {
                unusedparams = true,
                shadow = true,
              },
            },
          },
        },
      }

      -- Setup LSP servers
      for server_name, config in pairs(servers) do
        require("lspconfig")[server_name].setup({
          capabilities = capabilities,
          on_attach = on_attach,
          handlers = vim.tbl_deep_extend("force", {}, default_handlers, config.handlers or {}),
          settings = config.settings,
        })
      end

      -- Setup null-ls
      null_ls.setup({
        border = "rounded",
        sources = {
          -- Formatting
          null_ls.builtins.formatting.prettierd,
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.gofmt,
          null_ls.builtins.formatting.goimports,
        },
      })

      -- Set default border for LSP windows
      require("lspconfig.ui.windows").default_options.border = "rounded"
    end,
  },
}


-- Language servers: Mason installs them, mason-lspconfig enables them with
-- Neovim's built-in vim.lsp.enable(), nvim-lspconfig provides the defaults.
local servers = { "lua_ls", "pyright", "html", "cssls", "jsonls", "ts_ls", "tailwindcss" }

return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {
      ui = {
        border = "rounded",
        icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    opts = { ensure_installed = servers },
    config = function(_, opts)
      -- Completion capabilities for every server
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
            telemetry = { enable = false },
          },
        },
      })

      require("mason-lspconfig").setup(opts)
    end,
  },

  -- Neovim API completion and types when editing this config
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
    },
  },

  -- Breadcrumbs in the winbar
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    opts = { lsp = { auto_attach = true }, highlight = true },
    init = function()
      vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
    end,
  },

  -- LSP progress in the corner
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },

  -- Pictograms in the completion menu
  { "onsails/lspkind.nvim", lazy = true },

  {
    "neovim/nvim-lspconfig",
    lazy = true,
    init = function()
      -- Neovim already maps grn (rename), gra (code action), grr (references),
      -- gri (implementation), gO (symbols) and K (hover). These add the rest.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
        callback = function(args)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
          end
          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<leader>ct", vim.lsp.buf.type_definition, "Type definition")
          map({ "n", "x" }, "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, "Format")
          map("n", "<leader>ch", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
          end, "Toggle inlay hints")
        end,
      })
    end,
  },
}

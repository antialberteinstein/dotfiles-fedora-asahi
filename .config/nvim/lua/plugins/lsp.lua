-- Language servers. Mason installs them (lua/config/tools.lua), mason-lspconfig
-- enables the Mason-installed ones with vim.lsp.enable(), nvim-lspconfig
-- provides each server's defaults. clangd comes from Fedora, so it is enabled
-- here directly.
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
      "saghen/blink.cmp",
    },
    config = function()
      -- Completion capabilities for every server
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
            telemetry = { enable = false },
          },
        },
      })

      -- C/C++: assume C++17 when a project has no compile_commands.json,
      -- which is the usual case for competitive programming files.
      vim.lsp.config("clangd", {
        init_options = { fallbackFlags = { "-std=c++17" } },
      })
      if vim.fn.executable("clangd") == 1 then
        vim.lsp.enable("clangd")
      end

      require("config.tools").ensure()
      -- Enables every server Mason has installed
      require("mason-lspconfig").setup()
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

  {
    "neovim/nvim-lspconfig",
    lazy = true,
    init = function()
      -- Neovim already maps grn (rename), gra (code action), grr (references),
      -- gri (implementation), gO (symbols) and K (hover). These add the rest.
      -- Formatting is <leader>cf from conform.nvim (lua/plugins/formatting.lua).
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          -- pyright answers hover in Python files; ruff only lints and formats
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
          end
          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<leader>ct", vim.lsp.buf.type_definition, "Type definition")
          map("n", "<leader>ch", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
          end, "Toggle inlay hints")
        end,
      })
    end,
  },
}

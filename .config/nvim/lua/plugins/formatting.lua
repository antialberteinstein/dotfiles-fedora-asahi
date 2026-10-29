-- Format on save with conform.nvim. Languages without a formatter listed here
-- fall back to their language server (e.g. clangd for C/C++).
-- <leader>cf formats, <leader>ct toggles format on save, <leader>ci shows info.
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      { "<leader>ci", "<Cmd>ConformInfo<CR>", desc = "Formatter info" },
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "x" },
        desc = "Format",
      },
      {
        "<leader>ct",
        function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify("Format on save " .. (vim.g.disable_autoformat and "off" or "on"))
        end,
        desc = "Toggle format on save",
      },
    },
    opts = {
      formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
      },
      format_on_save = function()
        if vim.g.disable_autoformat then
          return nil
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    },
  },
}

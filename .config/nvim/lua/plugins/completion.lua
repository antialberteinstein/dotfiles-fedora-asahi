-- Completion with blink.cmp: LSP, paths, snippets (friendly-snippets) and
-- words from open buffers, plus Neovim API completion from lazydev.
-- Version 1.* downloads a prebuilt fuzzy matcher (aarch64 included).
return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- Enter accepts, Tab/Shift+Tab move through the list and snippet fields,
      -- Ctrl+Space opens the menu, Ctrl+E closes it, Ctrl+B/F scroll the docs.
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        list = { selection = { preselect = false, auto_insert = true } },
        menu = { border = "rounded" },
        documentation = { auto_show = true, auto_show_delay_ms = 300, window = { border = "rounded" } },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}

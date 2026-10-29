-- Terminals with toggleterm. Ctrl+` toggles the floating terminal from normal,
-- insert and terminal mode; <leader>t picks a layout.
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<C-`>", mode = { "n", "i" }, desc = "Toggle terminal" },
      -- Without the kitty keyboard protocol (e.g. tmux without extended keys)
      -- Ctrl+` arrives as Ctrl+@. Not mapped in insert mode, where that is
      -- Ctrl+Space for completion.
      { "<C-@>", "<Cmd>ToggleTerm<CR>", mode = { "n", "t" }, desc = "Toggle terminal" },
      { "<leader>tt", "<Cmd>ToggleTerm direction=float<CR>", desc = "Floating terminal" },
      { "<leader>th", "<Cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal terminal" },
      { "<leader>tv", "<Cmd>ToggleTerm direction=vertical size=80<CR>", desc = "Vertical terminal" },
      { "<leader>gg", "<Cmd>lua LazygitToggle()<CR>", desc = "LazyGit" },
    },
    init = function()
      -- Global so the dashboard and keymaps can open LazyGit in a float.
      function _G.LazygitToggle()
        if vim.fn.executable("lazygit") == 0 then
          vim.notify("lazygit is not installed (run scripts/packages.sh)", vim.log.levels.WARN)
          return
        end
        local Terminal = require("toggleterm.terminal").Terminal
        _G._lazygit_term = _G._lazygit_term
          or Terminal:new({ cmd = "lazygit", hidden = true, direction = "float", float_opts = { border = "curved" } })
        _G._lazygit_term:toggle()
      end
    end,
    opts = {
      open_mapping = "<C-`>",
      direction = "float",
      shade_terminals = true,
      start_in_insert = true,
      persist_size = true,
      close_on_exit = true,
      float_opts = { border = "curved" },
    },
  },
}

-- Ctrl+h/j/k/l move between Neovim splits and, inside tmux, tmux panes.
-- Outside tmux they behave like <C-w>h/j/k/l.
return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    init = function()
      -- Only the four directions; Ctrl+\ stays the toggleterm key
      vim.g.tmux_navigator_no_mappings = 1
    end,
    keys = {
      { "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", desc = "Go to left split/pane" },
      { "<C-j>", "<Cmd>TmuxNavigateDown<CR>", desc = "Go to lower split/pane" },
      { "<C-k>", "<Cmd>TmuxNavigateUp<CR>", desc = "Go to upper split/pane" },
      { "<C-l>", "<Cmd>TmuxNavigateRight<CR>", desc = "Go to right split/pane" },
    },
  },
}

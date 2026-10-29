return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { [[<C-\>]], desc = "Toggle terminal" },
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
      open_mapping = [[<C-\>]],
      direction = "float",
      shade_terminals = true,
      start_in_insert = true,
      persist_size = true,
      close_on_exit = true,
      -- Use fish inside the terminal when it is installed
      shell = vim.fn.executable("fish") == 1 and "fish" or vim.o.shell,
      float_opts = { border = "curved" },
    },
  },
}

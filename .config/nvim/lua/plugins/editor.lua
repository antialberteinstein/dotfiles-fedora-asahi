return {
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    keys = {
      { "<leader>ee", "<Cmd>Neotree toggle<CR>", desc = "Toggle explorer" },
      { "<leader>er", "<Cmd>Neotree reveal<CR>", desc = "Reveal current file" },
      { "<leader>eg", "<Cmd>Neotree float git_status<CR>", desc = "Git status" },
      { "<leader>eb", "<Cmd>Neotree float buffers<CR>", desc = "Open buffers" },
    },
    -- Open neo-tree instead of netrw when starting with a directory: nvim .
    init = function()
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("neotree_start_directory", { clear = true }),
        once = true,
        callback = function()
          if package.loaded["neo-tree"] then
            return
          end
          local stats = vim.uv.fs_stat(vim.fn.argv(0) --[[@as string]])
          if stats and stats.type == "directory" then
            require("neo-tree")
          end
        end,
      })
    end,
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      default_component_configs = {
        indent = { with_markers = true, indent_marker = "│", last_indent_marker = "└" },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            deleted = "✖",
            renamed = "󰁕",
            untracked = "",
            ignored = "",
            unstaged = "󰄱",
            staged = "",
            conflict = "",
          },
        },
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        hijack_netrw_behavior = "open_current",
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = { ".DS_Store", "thumbs.db" },
        },
      },
    },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader>ff", "<Cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "Search in files" },
      { "<leader>fw", "<Cmd>Telescope grep_string<CR>", desc = "Search word under cursor" },
      { "<leader>fb", "<Cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fr", "<Cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "Help" },
      { "<leader>fc", "<Cmd>Telescope commands<CR>", desc = "Commands" },
      { "<leader>fk", "<Cmd>Telescope keymaps<CR>", desc = "Keymaps" },
      { "<leader>fd", "<Cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
      { "<leader>fe", "<Cmd>Telescope file_browser<CR>", desc = "File browser" },
      { "<leader>f.", "<Cmd>Telescope resume<CR>", desc = "Resume last search" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "smart" },
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            },
            n = {
              ["q"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = { hidden = true, file_ignore_patterns = { "^.git/" } },
          live_grep = { only_sort_text = true },
          buffers = {
            initial_mode = "normal",
            mappings = { n = { ["dd"] = actions.delete_buffer } },
          },
          colorscheme = { enable_preview = true },
        },
        extensions = {
          file_browser = { theme = "dropdown", hijack_netrw = false },
        },
      })
      pcall(telescope.load_extension, "fzf")
      telescope.load_extension("file_browser")
    end,
  },

  -- Surround text objects: ys, ds, cs
  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },

  -- Auto-close brackets and quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      disable_filetype = { "TelescopePrompt" },
      fast_wrap = { map = "<M-e>" },
    },
  },

  -- Highlight TODO, FIXME, NOTE...
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ft", "<Cmd>TodoTelescope<CR>", desc = "Find TODOs" },
    },
    opts = {},
  },

  -- Diagnostics, references and symbols lists
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (project)" },
      { "<leader>xb", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Diagnostics (buffer)" },
      { "<leader>xs", "<Cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols" },
      { "<leader>xr", "<Cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP references" },
      { "<leader>xq", "<Cmd>Trouble qflist toggle<CR>", desc = "Quickfix list" },
    },
    opts = {},
  },

  -- Comment strings that follow the language under the cursor (JSX, Vue,
  -- embedded Lua...). Plugs into Neovim's built-in gc commenting.
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = { "BufReadPost", "BufNewFile" },
    opts = { enable_autocmd = false },
    config = function(_, opts)
      require("ts_context_commentstring").setup(opts)
      local get_option = vim.filetype.get_option
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.filetype.get_option = function(filetype, option)
        if option == "commentstring" then
          return require("ts_context_commentstring.internal").calculate_commentstring() or get_option(filetype, option)
        end
        return get_option(filetype, option)
      end
    end,
  },
}

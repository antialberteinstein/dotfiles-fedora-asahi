return {
  { "nvim-tree/nvim-web-devicons", lazy = true, opts = { color_icons = true, default = true } },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "│", right = "│" },
        disabled_filetypes = { statusline = { "dashboard" } },
      },
      sections = {
        lualine_a = { { "mode", separator = { left = "", right = "" } } },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          { "filename", path = 1, symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" } },
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { { "location", separator = { left = "", right = "" } } },
      },
      extensions = { "neo-tree", "toggleterm", "lazy", "mason", "trouble" },
    },
  },

  -- Buffer tabs
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    keys = {
      { "<leader>bn", "<Cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
      { "<leader>bp", "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
      { "<leader>bd", "<Cmd>bdelete<CR>", desc = "Delete buffer" },
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Close other buffers" },
      { "<leader>bj", "<Cmd>BufferLinePick<CR>", desc = "Jump to buffer" },
      { "<leader>bc", "<Cmd>BufferLinePickClose<CR>", desc = "Pick buffer to close" },
    },
    opts = {
      options = {
        separator_style = "slant",
        always_show_bufferline = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        offsets = {
          { filetype = "neo-tree", text = "File Explorer", highlight = "Directory", text_align = "left" },
        },
      },
    },
  },

  -- Start screen
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function()
      local header = {
        "",
        "",
        " █████╗ ██╗     ██╗   ██╗██╗  ██╗ ██████╗ ███╗   ██╗",
        "██╔══██╗██║     ██║   ██║╚██╗██╔╝██╔═══██╗████╗  ██║",
        "███████║██║     ██║   ██║ ╚███╔╝ ██║   ██║██╔██╗ ██║",
        "██╔══██║██║     ██║   ██║ ██╔██╗ ██║   ██║██║╚██╗██║",
        "██║  ██║███████╗╚██████╔╝██╔╝ ██╗╚██████╔╝██║ ╚████║",
        "╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝",
        "       ━━━━━━━━━━ ━━━━━━━━━☭━━━━━━━━━ ━━━━━━━━━",
        "",
      }
      return {
        theme = "doom",
        config = {
          header = header,
          center = {
            { icon = "  ", desc = "Find file", action = "Telescope find_files", key = "f" },
            { icon = "  ", desc = "Recent files", action = "Telescope oldfiles", key = "r" },
            { icon = "  ", desc = "File browser", action = "Telescope file_browser", key = "b" },
            { icon = "  ", desc = "New file", action = "enew", key = "n" },
            { icon = "  ", desc = "LazyGit", action = "lua LazygitToggle()", key = "g" },
            { icon = "󰒲  ", desc = "Plugins", action = "Lazy", key = "p" },
            { icon = "  ", desc = "Configuration", action = "edit $MYVIMRC", key = "c" },
            { icon = "  ", desc = "Quit", action = "qa", key = "q" },
          },
          footer = function()
            local stats = require("lazy").stats()
            return {
              "",
              ("Neovim loaded %d/%d plugins in %.0f ms"):format(stats.loaded, stats.count, stats.startuptime),
            }
          end,
        },
      }
    end,
  },

  -- Command line, messages and LSP docs UI
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    keys = {
      {
        "<leader>nd",
        function()
          require("noice").cmd("dismiss")
        end,
        desc = "Dismiss messages",
      },
      {
        "<leader>nh",
        function()
          require("noice").cmd("history")
        end,
        desc = "Message history",
      },
      {
        "<leader>nl",
        function()
          require("noice").cmd("last")
        end,
        desc = "Last message",
      },
    },
    opts = {
      cmdline = {
        view = "cmdline_popup",
        format = {
          cmdline = { pattern = "^:", icon = "󰘳 ", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = "$ ", lang = "bash" },
        },
      },
      messages = { view = "mini", view_error = "notify", view_warn = "notify" },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        -- blink.cmp shows signature help
        signature = { enabled = false },
      },
      presets = {
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
      routes = {
        { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
      },
    },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = true, show_start = true, show_end = false },
      exclude = { filetypes = { "dashboard", "lazy", "mason", "neo-tree" } },
    },
  },

  -- Show colours like #7aa2f7 inline
  {
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    keys = { { "<leader>uc", "<Cmd>ColorizerToggle<CR>", desc = "Toggle color preview" } },
    opts = {
      filetypes = { "*" },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        RRGGBBAA = true,
        names = false,
        css = true,
        css_fn = true,
        tailwind = true,
        mode = "background",
      },
    },
  },

  -- Keymap hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        -- One prefix per plugin: <leader> + plugin letter + action letter
        { "<leader>b", group = "buffers (bufferline)" },
        { "<leader>c", group = "format (conform)" },
        { "<leader>e", group = "explorer (neo-tree)" },
        { "<leader>f", group = "find (telescope)" },
        { "<leader>g", group = "git (gitsigns, lazygit)" },
        { "<leader>l", group = "lsp" },
        { "<leader>n", group = "notifications (noice)" },
        { "<leader>p", group = "competitive programming (competitest)" },
        { "<leader>t", group = "terminal (toggleterm)" },
        { "<leader>u", group = "ui toggles" },
        { "<leader>x", group = "diagnostics (trouble)" },
      },
    },
    keys = {
      { "?", "<Cmd>Telescope keymaps<CR>", desc = "Search keymaps" },
    },
  },
}

local opt = vim.opt

-- Files and encoding
opt.fileencoding = "utf-8"
opt.backup = false
opt.swapfile = false
opt.undofile = true

-- Clipboard: share with the system (needs wl-clipboard on Wayland)
opt.clipboard = "unnamedplus"
opt.mouse = "a"

-- Indentation: 4 spaces
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true
opt.wrap = false

-- Interface
opt.number = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "80"
opt.scrolloff = 10
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.showmode = false -- lualine shows the mode
opt.title = true
opt.laststatus = 3 -- one global statusline
opt.pumblend = 5
opt.winborder = "rounded" -- borders on LSP hover and other floats

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.path:append("**")
opt.wildignore:append("*/node_modules/*")

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Continue comments on <Enter>
opt.formatoptions:append("r")

-- Faster CursorHold (used by gitsigns and LSP highlights)
opt.updatetime = 250
opt.timeoutlen = 400

-- General keymaps. Plugin keymaps live next to their plugin in lua/plugins/.
-- Press <Space> and wait to see everything in which-key, or ? to search.
local map = vim.keymap.set

-- Save with Ctrl+S in every mode
map({ "n", "i", "x", "s" }, "<C-s>", "<Cmd>write<CR><Esc>", { desc = "Save file" })

-- Clear search highlight
map("n", "<Esc>", "<Cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlight" })

-- Move through wrapped lines naturally
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move selected lines up and down
map("x", "J", ":move '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })
map("x", "K", ":move '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })

-- Keep the selection after indenting
map("x", "<", "<gv")
map("x", ">", ">gv")

-- Toggle comments with Ctrl+/ (terminals send it as <C-_>)
map("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment" })
map("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment" })
map("x", "<C-/>", "gc", { remap = true, desc = "Toggle comment" })
map("x", "<C-_>", "gc", { remap = true, desc = "Toggle comment" })

-- Buffers
map("n", "<S-l>", "<Cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Windows
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Leave terminal mode with a double Esc
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Diagnostics
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

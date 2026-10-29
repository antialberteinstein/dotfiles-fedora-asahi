-- Settings that only apply when running inside the Neovide GUI.
if not vim.g.neovide then
  return
end

vim.o.guifont = "JetBrainsMono Nerd Font:h14"

vim.g.neovide_opacity = 0.90
vim.g.neovide_window_blurred = true
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0

vim.g.neovide_cursor_animation_length = 0.05
vim.g.neovide_cursor_trail_size = 0.1
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_cursor_vfx_mode = "sonicboom"

vim.g.neovide_hide_mouse_when_typing = true
vim.g.neovide_confirm_quit = true

-- VS Code-style Super/Cmd shortcuts. Neovide receives the Super key, a
-- terminal does not, so these only make sense here.
local map = vim.keymap.set
map({ "n", "i", "x" }, "<D-s>", "<Cmd>write<CR>", { desc = "Save file" })
map("n", "<D-w>", "<Cmd>bdelete<CR>", { desc = "Close buffer" })
map("n", "<D-n>", "<Cmd>enew<CR>", { desc = "New file" })
map("x", "<D-c>", '"+y', { desc = "Copy" })
map("x", "<D-x>", '"+x', { desc = "Cut" })
map({ "n", "x" }, "<D-v>", '"+p', { desc = "Paste" })
map({ "i", "c" }, "<D-v>", "<C-r>+", { desc = "Paste" })
map("n", "<D-a>", "ggVG", { desc = "Select all" })
map("n", "<D-z>", "u", { desc = "Undo" })
map("n", "<D-Z>", "<C-r>", { desc = "Redo" })
map("n", "<D-/>", "gcc", { remap = true, desc = "Toggle comment" })
map("x", "<D-/>", "gc", { remap = true, desc = "Toggle comment" })
map("n", "<D-b>", "<Cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })
map("n", "<D-p>", "<Cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<D-P>", "<Cmd>Telescope commands<CR>", { desc = "Command palette" })
map("n", "<D-F>", "<Cmd>Telescope live_grep<CR>", { desc = "Search in files" })

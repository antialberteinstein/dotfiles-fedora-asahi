-- Headless smoke test for the Neovim config.
--
--   nvim --headless "+Lazy! sync" +qa
--   SMOKE_FULL=1 nvim --headless -c "luafile tests/nvim-smoke.lua"
--
-- SMOKE_FULL=1 also downloads treesitter parsers and language servers and
-- checks that highlighting and LSP work. Without it only offline checks run.
local failures = {}
local function fail(msg)
  table.insert(failures, msg)
end
local full = os.getenv("SMOKE_FULL") == "1"

local sample = vim.fn.tempname() .. ".py"
vim.fn.writefile({ "def greet(name: str) -> str:", "    return 'hi ' + name", "" }, sample)

if full then
  -- Treesitter parsers
  local ok, err = pcall(function()
    require("nvim-treesitter").install({ "lua", "python", "bash", "fish", "markdown" }):wait(300000)
  end)
  if not ok then
    fail("treesitter install: " .. tostring(err))
  end

  -- Language servers through Mason (lua_ls and pyright prove the pipeline)
  require("lazy").load({ plugins = { "mason-lspconfig.nvim" } })
  local registry = require("mason-registry")
  registry.refresh()
  for _, name in ipairs({ "lua-language-server", "pyright" }) do
    local found, pkg = pcall(registry.get_package, name)
    if not found then
      fail("mason package not found: " .. name)
    elseif not pkg:is_installed() then
      local done = false
      pkg:install({}, function()
        done = true
      end)
      vim.wait(300000, function()
        return done
      end, 500)
      if not pkg:is_installed() then
        fail("mason install failed: " .. name)
      end
    end
  end

  -- Open real files: highlighting and LSP must attach
  local cases = {
    { file = vim.fn.stdpath("config") .. "/lua/config/options.lua", lang = "lua", lsp = "lua_ls" },
    { file = sample, lang = "python", lsp = "pyright" },
  }
  for _, c in ipairs(cases) do
    vim.cmd.edit(c.file)
    local buf = vim.api.nvim_get_current_buf()
    vim.wait(10000, function()
      return vim.treesitter.highlighter.active[buf] ~= nil
    end, 100)
    if not vim.treesitter.highlighter.active[buf] then
      fail("no treesitter highlighting for " .. c.lang)
    end
    vim.wait(60000, function()
      return #vim.lsp.get_clients({ bufnr = buf, name = c.lsp }) > 0
    end, 200)
    if #vim.lsp.get_clients({ bufnr = buf, name = c.lsp }) == 0 then
      fail(c.lsp .. " did not attach")
    end
  end
end

-- Commenting with gcc (built in, through ts-context-commentstring)
vim.cmd.edit(sample)
vim.api.nvim_win_set_cursor(0, { 1, 0 })
vim.cmd("normal gcc")
local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
if not line:match("^# def") then
  fail("gcc did not comment a python line: " .. line)
end
vim.cmd("normal gcc")

-- Keymaps and commands
for _, lhs in ipairs({ "<Space>ff", "<Space>fg", "<Space>e", "<Space>gg", "<Space>xx", "<C-S>", "<C-/>" }) do
  if vim.fn.maparg(lhs, "n") == "" then
    fail("missing keymap " .. lhs)
  end
end
for _, cmd in ipairs({ "Telescope", "Neotree", "Trouble", "Mason", "Lazy", "ToggleTerm" }) do
  if vim.fn.exists(":" .. cmd) == 0 then
    fail("missing command :" .. cmd)
  end
end
for _, cmd in ipairs({ "Telescope find_files", "Neotree toggle", "Trouble diagnostics toggle" }) do
  local ok, err = pcall(vim.cmd, cmd)
  if not ok then
    fail(cmd .. ": " .. tostring(err))
  end
end

-- Errors reported while starting up
local messages = vim.api.nvim_exec2("messages", { output = true }).output
for msg in messages:gmatch("[^\n]+") do
  local offline_download = not full and msg:match("Error during download")
  if not offline_download and (msg:match("E%d+:") or msg:lower():match("error")) then
    fail("message: " .. msg)
  end
end

if #failures > 0 then
  io.stdout:write("SMOKE TEST FAILED\n  " .. table.concat(failures, "\n  ") .. "\n")
  vim.cmd("cquit 1")
else
  io.stdout:write(("SMOKE TEST PASSED (%s)\n"):format(full and "full" or "offline"))
  vim.cmd("qall!")
end

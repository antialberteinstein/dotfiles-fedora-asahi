-- Language servers and formatters installed with Mason. Neovim installs any
-- that are missing in the background at startup; update.sh waits for them.
-- clangd is not here: Mason only ships it for x86_64 Linux, so it comes from
-- Fedora's clang-tools-extra package instead (scripts/packages.sh).
local M = {}

M.packages = {
  -- Language servers
  "lua-language-server",
  "pyright",
  "ruff",
  "html-lsp",
  "css-lsp",
  "json-lsp",
  "typescript-language-server",
  "tailwindcss-language-server",
  -- Formatters used by conform.nvim
  "stylua",
  "prettier",
}

local pending = 0

--- Install every package in M.packages that is not installed yet.
function M.ensure()
  local registry = require("mason-registry")
  registry.refresh(function()
    for _, name in ipairs(M.packages) do
      local ok, pkg = pcall(registry.get_package, name)
      if ok and not pkg:is_installed() and not pkg:is_installing() then
        pending = pending + 1
        pkg:install({}, function(success)
          pending = pending - 1
          if not success then
            vim.schedule(function()
              vim.notify("Mason could not install " .. name, vim.log.levels.WARN)
            end)
          end
        end)
      end
    end
  end)
end

--- Block until installs started by M.ensure() finish (used by update.sh).
---@param timeout_ms integer
function M.wait(timeout_ms)
  -- Give the registry refresh a moment to start the installs
  vim.wait(3000, function()
    return pending > 0
  end, 100)
  return vim.wait(timeout_ms, function()
    return pending == 0
  end, 500)
end

return M

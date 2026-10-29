-- Install treesitter parsers without ever running two installs of the same
-- parser at once (they share a temp directory and would fail).
local M = {}

-- Parsers installed in the background on the first start.
M.parsers = {
  "bash",
  "c",
  "cpp",
  "css",
  "dockerfile",
  "fish",
  "html",
  "java",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

---@type table<string, table> language -> install task still running
local pending = {}

local function track(langs, task)
  for _, lang in ipairs(langs) do
    pending[lang] = task
  end
  task:await(function()
    for _, lang in ipairs(langs) do
      if pending[lang] == task then
        pending[lang] = nil
      end
    end
  end)
  return task
end

--- Start installing every parser in M.parsers that is missing.
function M.install_all()
  local ts = require("nvim-treesitter")
  local installed = ts.get_installed()
  local missing = vim.tbl_filter(function(lang)
    return not vim.list_contains(installed, lang) and not pending[lang]
  end, M.parsers)
  if #missing > 0 then
    track(missing, ts.install(missing))
  end
end

--- Call `callback` once `lang` is installed, installing it if needed.
--- Does nothing if there is no parser for `lang`.
---@param lang string
---@param callback fun()
function M.when_installed(lang, callback)
  local ts = require("nvim-treesitter")
  if vim.list_contains(ts.get_installed(), lang) then
    return callback()
  end
  local task = pending[lang]
  if not task then
    if not vim.list_contains(ts.get_available(), lang) then
      return
    end
    task = track({ lang }, ts.install(lang))
  end
  task:await(vim.schedule_wrap(function()
    if vim.list_contains(ts.get_installed(), lang) then
      callback()
    end
  end))
end

--- Block until every running install has finished (used by tests).
---@param timeout_ms integer
function M.wait(timeout_ms)
  return vim.wait(timeout_ms, function()
    return next(pending) == nil
  end, 200)
end

return M

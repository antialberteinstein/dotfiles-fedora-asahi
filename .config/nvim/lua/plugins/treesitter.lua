-- nvim-treesitter (main branch) installs parsers and queries; Neovim itself
-- does the highlighting. Needs tree-sitter-cli and a C compiler.
local parsers = {
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

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
          if not lang then
            return
          end

          -- Skip very large files to keep editing fast
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > 100 * 1024 then
            return
          end

          -- Install missing parsers on demand, then start highlighting
          if not vim.list_contains(ts.get_installed(), lang) then
            if not vim.list_contains(ts.get_available(), lang) then
              return
            end
            ts.install(lang):await(function()
              if vim.api.nvim_buf_is_valid(buf) then
                pcall(vim.treesitter.start, buf, lang)
              end
            end)
            return
          end

          if pcall(vim.treesitter.start, buf, lang) and lang ~= "yaml" then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}

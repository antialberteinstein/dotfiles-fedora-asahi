-- nvim-treesitter (main branch) installs parsers and queries; Neovim itself
-- does the highlighting. Needs tree-sitter-cli and a C compiler.
-- Parser installs go through lua/config/treesitter.lua so the same parser is
-- never installed twice at the same time.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local parsers = require("config.treesitter")
      parsers.install_all()

      local function start(buf, lang)
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        if pcall(vim.treesitter.start, buf, lang) and lang ~= "yaml" then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

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

          parsers.when_installed(lang, function()
            start(buf, lang)
          end)
        end,
      })
    end,
  },
}

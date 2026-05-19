local profile = vim.g.nvim_profile or "typescript"

local common_parsers = {
  "lua",
  "vim",
  "vimdoc",
  "json",
  "sql",
  "gitignore",
}

local profile_parsers = {
  typescript = {
    "javascript",
    "typescript",
    "tsx",
    "css",
    "scss",
    "graphql",
    "http",
    "html",
  },
  java = {
    "java",
    "xml",
    "kotlin",
    "gradle",
  },
}

local ensure_installed = vim.list_extend(vim.deepcopy(common_parsers), profile_parsers[profile] or {})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = ensure_installed,
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
    },
  },
}

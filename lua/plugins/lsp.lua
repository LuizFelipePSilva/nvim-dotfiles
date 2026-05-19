local profile = vim.g.nvim_profile or "typescript"

-- Servers instalados via Mason por profile
local common_servers = {
  "lua-language-server",
  "stylua",
  "shellcheck",
  "shfmt",
  "luacheck",
}

local profile_servers = {
  typescript = {
    "tailwindcss-language-server",
    "json-lsp",
    "angular-language-server",
    "dockerfile-language-server",
    "css-lsp",
    "eslint-lsp",
    "prettier",
  },
  java = {
    "jdtls",
    "google-java-format",
    "checkstyle",
    "sonarlint-language-server",
  },
}

local ensure_installed = vim.list_extend(vim.deepcopy(common_servers), profile_servers[profile] or {})

-- LSP servers configurados por profile
local typescript_servers = {
  eslint = {
    root_dir = require("lspconfig.util").root_pattern(
      "eslint.config.js",
      ".eslintrc.js",
      ".eslintrc.cjs",
      ".eslintrc.json",
      "package.json",
      ".git"
    ),
  },

  angularls = {
    filetypes = { "typescript", "html", "angular", "typescript.angular", "htmlangular" },
  },

  cssls = {},
  html = {},

  tailwindcss = {
    root_dir = function(...)
      return require("lspconfig.util").root_pattern(".git")(...)
    end,
  },

  react = {
    root_dir = function(...)
      return require("lspconfig.util").root_pattern(".git")(...)
    end,
  },

  nextls = {
    root_dir = function(...)
      return require("lspconfig.util").root_pattern("next.config.js", "next.config.ts", ".git")(...)
    end,
  },
}

local java_servers = {
  -- jdtls é gerenciado pelo nvim-jdtls diretamente (plugin java.lua)
  -- Aqui ficam apenas servers extras para Java que rodam via lspconfig
}

local profile_lsp_servers = profile == "typescript" and typescript_servers or profile == "java" and java_servers or {}

-- Sempre presente independente do profile
local common_lsp_servers = {
  lua_ls = {
    single_file_support = true,
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        completion = { workspaceWord = true, callSnippet = "Both" },
        hint = {
          enable = true,
          setType = false,
          paramType = true,
          paramName = "Disable",
          semicolon = "Disable",
          arrayIndex = "Disable",
        },
        diagnostics = {
          disable = { "incomplete-signature-doc", "trailing-space" },
          groupSeverity = { strong = "Warning", strict = "Warning" },
        },
        format = { enable = false },
      },
    },
  },
}

local servers = vim.tbl_deep_extend("force", common_lsp_servers, profile_lsp_servers)

return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, ensure_installed)
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
      servers = servers,
    },
  },
}

-- NOTE: O código de bootstrap foi movido para init.lua

require("lazy").setup({
  spec = {
    -- Carrega os plugins padrão do LazyVim
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- Importa todos os seus plugins da pasta lua/plugins
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

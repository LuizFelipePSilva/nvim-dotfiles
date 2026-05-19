-- NOTE: Bootstrap está no init.lua

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
  },
  defaults = {
    lazy = true, -- alterado de false para true (melhora startup time)
    version = false,
  },
  install = { colorscheme = { "gruvbox", "tokyonight", "habamax" } },
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
        "matchit",
        "matchparen",
        "netrwPlugin",
        "rplugin",
        "spellfile",
      },
    },
  },
})

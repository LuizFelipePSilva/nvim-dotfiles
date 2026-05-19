-- ============================================================
-- AI — CodeCompanion (Claude)
-- Requer: ANTHROPIC_API_KEY no ambiente
-- export ANTHROPIC_API_KEY="sk-ant-..."  → ~/.zshrc ou ~/.bashrc
-- ============================================================

return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionActions<CR>", mode = { "n", "v" }, desc = "AI Actions" },
      { "<leader>ac", "<cmd>CodeCompanionChat<CR>", mode = { "n", "v" }, desc = "AI Chat" },
      { "<leader>ai", "<cmd>CodeCompanion<CR>", mode = { "n", "v" }, desc = "AI Inline" },
    },
    opts = {
      adapters = {
        chat = "anthropic",
        inline = "anthropic",
      },
      strategies = {
        chat = {
          adapter = "anthropic",
          model = "claude-sonnet-4-20250514",
        },
        inline = {
          adapter = "anthropic",
          model = "claude-sonnet-4-20250514",
        },
      },
      display = {
        chat = {
          window = {
            layout = "vertical",
            width = 0.35,
          },
        },
      },
    },
  },
}

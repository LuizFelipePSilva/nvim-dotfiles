-- ============================================================
-- GIT DIFF — Diffview
-- <leader>gd  → diff branch atual vs main
-- <leader>gh  → histórico do arquivo atual
-- q           → fecha diffview
-- ============================================================

return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      {
        "<leader>gd",
        function()
          -- Tenta main, cai para master se não existir
          local branch = vim.fn.system("git rev-parse --verify main 2>/dev/null") ~= "" and "main" or "master"
          vim.cmd("DiffviewOpen " .. branch .. "..HEAD")
        end,
        desc = "Diff vs main",
      },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File History" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Repo History" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
      },
      file_panel = {
        listing_style = "tree",
        win_config = { width = 30 },
      },
      keymaps = {
        view = {
          { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
        },
        file_panel = {
          { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
        },
        file_history_panel = {
          { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
        },
      },
    },
  },
}

if vim.g.nvim_profile ~= "typescript" then
  return {}
end

return {
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = {
      settings = {
        -- Melhora performance: desativa features pesadas se não precisar
        tsserver_max_memory = 4096,
        expose_as_code_action = "all",
        jsx_close_tag = {
          enable = true,
          filetypes = { "javascriptreact", "typescriptreact" },
        },
      },
    },
    keys = {
      { "<leader>co", "<cmd>TSToolsOrganizeImports<CR>", desc = "Organize Imports" },
      { "<leader>cR", "<cmd>TSToolsRenameFile<CR>", desc = "Rename File" },
      { "<leader>ci", "<cmd>TSToolsAddMissingImports<CR>", desc = "Add Missing Imports" },
      { "<leader>cu", "<cmd>TSToolsRemoveUnusedImports<CR>", desc = "Remove Unused Imports" },
    },
  },
}

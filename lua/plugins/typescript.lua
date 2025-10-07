return {
  {
    "jose-elias-alvarez/typescript.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("typescript").setup({})
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buf = args.buf
          vim.keymap.set(
            "n",
            "<leader>co",
            "<cmd>TypescriptOrganizeImports<CR>",
            { buffer = buf, desc = "Organize Imports" }
          )
          vim.keymap.set("n", "<leader>cR", "<cmd>TypescriptRenameFile<CR>", { buffer = buf, desc = "Rename File" })
        end,
      })
    end,
  },
}

-- ============================================================
-- PROJECT — project.nvim
-- Muda cwd automaticamente para o root do projeto ao abrir buffer.
-- Detecta root por: .git, pom.xml, package.json, build.gradle
-- Integra automaticamente com NvimTree e Telescope.
-- Sem keymaps — age de forma transparente.
-- ============================================================

return {
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      require("project_nvim").setup({
        -- Estratégia de detecção: tenta lsp primeiro, depois pattern
        detection_methods = { "lsp", "pattern" },

        patterns = {
          ".git",
          "pom.xml",
          "build.gradle",
          "package.json",
          "Makefile",
          ".nvim", -- permite root manual com pasta .nvim/
        },

        -- Não muda cwd ao abrir um arquivo dentro de node_modules ou .git
        exclude_dirs = { "*/node_modules/*", "*/.git/*" },

        silent_chdir = true, -- não notifica ao mudar cwd

        -- Mostra projetos recentes no Telescope: <leader>fp já funciona,
        -- adicione este keymap se quiser listar projetos recentes:
        -- <leader>fP → :Telescope projects
      })

      -- Integração com Telescope
      local ok, telescope = pcall(require, "telescope")
      if ok then
        telescope.load_extension("projects")

        vim.keymap.set("n", "<leader>fP", "<cmd>Telescope projects<CR>", { desc = "Recent Projects" })
      end
    end,
  },
}

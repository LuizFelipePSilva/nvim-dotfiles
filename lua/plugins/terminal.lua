-- ============================================================
-- TERMINAL — ToggleTerm
-- Substitui M.run_in_term de keymaps.lua
-- <C-\>       → toggle terminal principal
-- <leader>rr  → mvn spring-boot:run (instância dedicada)
-- <leader>rj  → mvn compile exec:java (instância dedicada)
-- ============================================================

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Toggle Terminal" },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.35)
        end
      end,
      open_mapping = nil, -- gerenciado manualmente acima
      shade_terminals = false,
      start_in_insert = true,
      persist_mode = true,
      direction = "horizontal",
      close_on_exit = false, -- mantém output visível após o processo encerrar
      shell = vim.o.shell,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      local Terminal = require("toggleterm.terminal").Terminal

      -- Instância dedicada: Spring Boot
      local spring = Terminal:new({
        cmd = "mvn spring-boot:run",
        id = 10,
        direction = "horizontal",
        hidden = true,
        on_open = function(term)
          vim.cmd("startinsert!")
        end,
      })

      -- Instância dedicada: Java Main
      local java_main = Terminal:new({
        cmd = "mvn compile exec:java",
        id = 11,
        direction = "horizontal",
        hidden = true,
        on_open = function(term)
          vim.cmd("startinsert!")
        end,
      })

      vim.keymap.set("n", "<leader>rr", function()
        spring:toggle()
      end, { desc = "Run Spring Boot" })
      vim.keymap.set("n", "<leader>rj", function()
        java_main:toggle()
      end, { desc = "Run Java Main" })
    end,
  },
}

if vim.g.nvim_profile ~= "java" then
  return {}
end

return {
  -- ─── JDTLS (Java LSP) ────────────────────────────────────────────────────
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      local jdtls = require("jdtls")
      local mason_path = vim.fn.expand("~/.local/share/nvim/mason")
      local jdtls_bin = mason_path .. "/bin/jdtls"

      -- Workspace único por projeto (evita conflito entre projetos)
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
      local workspace_dir = vim.fn.expand("~/.local/share/nvim/jdtls-workspace/") .. project_name

      local config = {
        cmd = { jdtls_bin, "-data", workspace_dir },
        root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
        settings = {
          java = {
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
            completion = {
              favoriteStaticMembers = {
                "org.junit.Assert.*",
                "org.junit.jupiter.api.Assertions.*",
                "org.mockito.Mockito.*",
                "org.mockito.ArgumentMatchers.*",
                "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
                "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
              },
              filteredTypes = {
                "com.sun.*",
                "io.micrometer.shaded.*",
                "java.awt.*",
                "jdk.*",
                "sun.*",
              },
            },
            sources = {
              organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
              },
            },
            codeGeneration = {
              toString = {
                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
              },
              hashCodeEquals = {
                useJava7Objects = true,
              },
              useBlocks = true,
            },
            -- Spring Boot: habilita suporte a annotations
            configuration = {
              runtimes = {
                -- Ajuste os paths conforme sua instalação de JDK
                {
                  name = "JavaSE-17",
                  path = vim.fn.expand("~/.sdkman/candidates/java/17/"),
                },
                {
                  name = "JavaSE-21",
                  path = vim.fn.expand("~/.sdkman/candidates/java/21/"),
                },
              },
            },
          },
        },
        -- Habilita bundles extras (Lombok, Spring Boot Language Server, etc)
        init_options = {
          bundles = (function()
            local bundles = {}
            -- Lombok support
            local lombok = mason_path .. "/packages/jdtls/lombok.jar"
            if vim.fn.filereadable(lombok) == 1 then
              table.insert(bundles, lombok)
            end
            -- Spring Boot tools (se instalado via Mason)
            local spring_jar = vim.fn.glob(mason_path .. "/packages/spring-boot-tools/extension/jars/*.jar")
            if spring_jar ~= "" then
              table.insert(bundles, spring_jar)
            end
            return bundles
          end)(),
        },
        on_attach = function(client, bufnr)
          -- Keymaps específicos de Java
          local map = function(keys, cmd, desc)
            vim.keymap.set("n", keys, cmd, { buffer = bufnr, desc = desc })
          end
          map("<leader>co", "<cmd>lua require('jdtls').organize_imports()<CR>", "Organize Imports")
          map("<leader>ce", "<cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable")
          map("<leader>cm", "<cmd>lua require('jdtls').extract_method()<CR>", "Extract Method")
          map("<leader>cR", "<cmd>lua require('jdtls').rename()<CR>", "Rename")
          map("<leader>ct", "<cmd>lua require('jdtls').test_nearest_method()<CR>", "Test Method")
          map("<leader>cT", "<cmd>lua require('jdtls').test_class()<CR>", "Test Class")
          map("<leader>cb", "<cmd>lua require('jdtls').build_projects()<CR>", "Build Project")
        end,
      }

      -- Inicia ou re-attach ao entrar em buffer Java
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          jdtls.start_or_attach(config)
        end,
      })
    end,
  },

  -- ─── Spring Boot ─────────────────────────────────────────────────────────
  {
    "JavaHello/spring-boot.nvim",
    ft = "java",
    dependencies = { "mfussenegger/nvim-jdtls" },
    config = function()
      require("spring_boot").setup({
        ls_path = vim.fn.expand("~/.local/share/nvim/mason/packages/spring-boot-tools/extension/jars/"),
      })
    end,
  },

  -- ─── Treesitter para Java ────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "java", "xml", "kotlin" })
    end,
  },
}

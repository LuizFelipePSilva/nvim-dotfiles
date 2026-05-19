local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- ============================================================
-- Basic Keymaps
-- ============================================================

keymap.set("n", "x", '"_x')

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Save / Quit
keymap.set("n", "<Leader>w", ":update<CR>", opts)
keymap.set("n", "<Leader>q", ":quit<CR>", opts)
keymap.set("n", "<Leader>Q", ":qa<CR>", opts)

-- NvimTree
keymap.set("n", "<Leader>f", ":NvimTreeFindFile<CR>", opts)
keymap.set("n", "<Leader>t", ":NvimTreeToggle<CR>", opts)

-- Tabs
keymap.set("n", "te", ":tabedit<CR>", opts)
keymap.set("n", "tw", ":tabclose<CR>", opts)

-- Split window
keymap.set("n", "ss", ":split<CR>", opts)
keymap.set("n", "sv", ":vsplit<CR>", opts)

-- Move window
keymap.set("n", "sh", "<C-w>h", opts)
keymap.set("n", "sj", "<C-w>j", opts)
keymap.set("n", "sk", "<C-w>k", opts)
keymap.set("n", "sl", "<C-w>l", opts)

-- Resize window
keymap.set("n", "<C-S-h>", "<C-w><", opts)
keymap.set("n", "<C-S-l>", "<C-w>>", opts)
keymap.set("n", "<C-S-k>", "<C-w>+", opts)
keymap.set("n", "<C-S-j>", "<C-w>-", opts)

-- Save file
keymap.set("n", "<C-s>", ":update<CR>", { desc = "Save File" })
keymap.set("i", "<C-s>", "<Esc>:update<CR>a", { desc = "Save File" })

-- ============================================================
-- Helpers
-- ============================================================

local M = {}

M.ask = function(prompt, cb)
  vim.ui.input({ prompt = prompt }, function(value)
    if value and value ~= "" then
      cb(value)
    end
  end)
end

-- Substituído por ToggleTerm — mantém a mesma assinatura para
-- não quebrar chamadas existentes (jm, js)
M.run_in_term = function(cmd, cwd)
  local Terminal = require("toggleterm.terminal").Terminal
  Terminal:new({
    cmd = cmd,
    dir = cwd,
    direction = "horizontal",
    close_on_exit = false,
  }):toggle()
end

M.mkdir_p = function(path)
  vim.fn.mkdir(path, "p")
end

M.write_file = function(path, content)
  local file = assert(io.open(path, "w"))
  file:write(content)
  file:close()
end

-- ============================================================
-- Run Projects (instâncias persistentes via ToggleTerm)
-- ============================================================

local _spring_term = nil
local _java_term = nil

keymap.set("n", "<leader>rr", function()
  local Terminal = require("toggleterm.terminal").Terminal
  if not _spring_term then
    _spring_term = Terminal:new({
      cmd = "mvn spring-boot:run",
      id = 10,
      direction = "horizontal",
      close_on_exit = false,
    })
  end
  _spring_term:toggle()
end, { desc = "Run Spring Boot" })

keymap.set("n", "<leader>rj", function()
  local Terminal = require("toggleterm.terminal").Terminal
  if not _java_term then
    _java_term = Terminal:new({
      cmd = "mvn compile exec:java",
      id = 11,
      direction = "horizontal",
      close_on_exit = false,
    })
  end
  _java_term:toggle()
end, { desc = "Run Java Main" })

-- ============================================================
-- Templates
-- ============================================================

M.make_pom = function(group, artifact, version)
  return string.format(
    [[<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">

  <modelVersion>4.0.0</modelVersion>

  <groupId>%s</groupId>
  <artifactId>%s</artifactId>
  <version>%s</version>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.release>21</maven.compiler.release>
  </properties>

  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.junit</groupId>
        <artifactId>junit-bom</artifactId>
        <version>5.11.0</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>

  <dependencies>

    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter-api</artifactId>
      <scope>test</scope>
    </dependency>

    <dependency>
      <groupId>org.junit.jupiter</groupId>
      <artifactId>junit-jupiter-params</artifactId>
      <scope>test</scope>
    </dependency>

  </dependencies>

  <build>
    <plugins>

      <plugin>
        <groupId>org.codehaus.mojo</groupId>
        <artifactId>exec-maven-plugin</artifactId>
        <version>3.1.0</version>

        <configuration>
          <mainClass>%s.App</mainClass>
        </configuration>
      </plugin>

      <plugin>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.13.0</version>
      </plugin>

      <plugin>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.3.0</version>
      </plugin>

    </plugins>
  </build>

</project>]],
    group,
    artifact,
    version,
    group
  )
end

M.make_app = function(group)
  return string.format(
    [[package %s;

public class App {

    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }

}
]],
    group
  )
end

-- ============================================================
-- Generate Maven Project
-- ============================================================

keymap.set("n", "<leader>jm", function()
  M.ask("Group ID: ", function(group)
    M.ask("Artifact ID: ", function(artifact)
      M.ask("Version: ", function(version)
        local package_path = group:gsub("%.", "/")

        local base_dir = artifact
        local src_dir = base_dir .. "/src/main/java/" .. package_path
        local test_dir = base_dir .. "/src/test/java/" .. package_path

        M.mkdir_p(src_dir)
        M.mkdir_p(test_dir)

        M.write_file(base_dir .. "/pom.xml", M.make_pom(group, artifact, version))
        M.write_file(src_dir .. "/App.java", M.make_app(group))

        print("Maven project created: " .. artifact)

        M.run_in_term("mvn compile exec:java", base_dir)
      end)
    end)
  end)
end, { desc = "Generate Maven Project" })

-- ============================================================
-- Generate Spring Boot Project
-- ============================================================

keymap.set("n", "<leader>js", function()
  M.ask("Group ID: ", function(group)
    M.ask("Artifact ID: ", function(artifact)
      M.ask("Dependencies: ", function(deps)
        local url = table.concat({
          "https://start.spring.io/starter.zip",
          "?type=maven-project",
          "&language=java",
          "&bootVersion=3.4.0",
          "&groupId=" .. group,
          "&artifactId=" .. artifact,
          "&name=" .. artifact,
          "&javaVersion=21",
          "&dependencies=" .. deps,
        })

        local cmd = string.format(
          "curl -L -o %s.zip '%s' && unzip %s.zip -d %s && rm %s.zip",
          artifact,
          url,
          artifact,
          artifact,
          artifact
        )

        M.run_in_term(cmd)

        print("Spring Boot project created: " .. artifact)
      end)
    end)
  end)
end, { desc = "Generate Spring Boot Project" })

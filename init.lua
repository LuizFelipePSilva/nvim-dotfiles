-- ============================================================
-- PROFILE SELECTOR
-- Persiste o profile em ~/.local/share/nvim/profile
-- :ProfileReset  → reseta a escolha
-- :ProfileShow   → mostra o profile atual
-- :ProfileSelect → reabre o seletor manualmente
-- ============================================================

local profile_file = vim.fn.stdpath("data") .. "/profile"

local function read_profile()
  local f = io.open(profile_file, "r")
  if f then
    local p = f:read("*l")
    f:close()
    if p and p ~= "" then
      return p
    end
  end
end

local function save_profile(p)
  local f = io.open(profile_file, "w")
  if f then
    f:write(p)
    f:close()
  end
end

local function open_selector(callback)
  local profiles = {
    {
      id = "typescript",
      icon = {
        " ████████╗███████╗ ",
        "    ╚══██╔══╝██╔════╝ ",
        "       ██║   ███████╗ ",
        "       ██║   ╚════██║ ",
        "       ██║   ███████║ ",
        "       ╚═╝   ╚══════╝ ",
      },
      name = "TypeScript / Node.js",
      tags = { "NestJS", "Angular", "React", "Tailwind", "ESLint" },
      color = "ProfileBlue",
    },
    {
      id = "java",
      icon = {
        "    ██╗ █████╗ ██╗   ██╗ █████╗  ",
        "    ██║██╔══██╗██║   ██║██╔══██╗ ",
        "    ██║███████║██║   ██║███████║ ",
        "██  ██║██╔══██║╚██╗ ██╔╝██╔══██║ ",
        "╚█████╔╝██║  ██║ ╚████╔╝ ██║  ██║ ",
        " ╚════╝ ╚═╝  ╚═╝  ╚═══╝  ╚═╝  ╚═╝ ",
      },
      name = "Java / Spring Boot",
      tags = { "Spring Boot", "jdtls", "Lombok", "Maven", "Gradle" },
      color = "ProfileOrange",
    },
  }

  local width = 72
  local height = 38
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("filetype", "NvimProfile", { buf = buf })

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " ⚡ Select Profile ",
    title_pos = "center",
    noautocmd = true,
  })

  vim.api.nvim_set_option_value("cursorline", false, { win = win })
  vim.api.nvim_set_option_value("wrap", false, { win = win })

  vim.api.nvim_set_hl(0, "ProfileBlue", { fg = "#3d8bf0", bold = true })
  vim.api.nvim_set_hl(0, "ProfileBlueDim", { fg = "#1a4a8a" })
  vim.api.nvim_set_hl(0, "ProfileOrange", { fg = "#e8773a", bold = true })
  vim.api.nvim_set_hl(0, "ProfileOrangeDim", { fg = "#7a3a18" })
  vim.api.nvim_set_hl(0, "ProfileTag", { fg = "#888888" })
  vim.api.nvim_set_hl(0, "ProfileTagBlue", { fg = "#1e5fa8" })
  vim.api.nvim_set_hl(0, "ProfileTagOrange", { fg = "#a04e20" })
  vim.api.nvim_set_hl(0, "ProfileSelected", { fg = "#ffffff", bold = true })
  vim.api.nvim_set_hl(0, "ProfileDim", { fg = "#3a3a3a" })
  vim.api.nvim_set_hl(0, "ProfileHint", { fg = "#555555", italic = true })
  vim.api.nvim_set_hl(0, "ProfileName", { fg = "#cccccc", bold = true })
  vim.api.nvim_set_hl(0, "ProfileNameSel", { fg = "#ffffff", bold = true })

  local function build_lines(selected)
    local lines, hl_regions = {}, {}

    local function push(line, regions)
      table.insert(lines, line)
      table.insert(hl_regions, regions or {})
    end

    push("")
    push("  Choose your development environment", {})
    push("")

    for i, p in ipairs(profiles) do
      local is_sel = (selected == i)
      local icon_color = is_sel and p.color or (p.color == "ProfileBlue" and "ProfileBlueDim" or "ProfileOrangeDim")
      local tag_color = is_sel and (p.color == "ProfileBlue" and "ProfileTagBlue" or "ProfileTagOrange") or "ProfileTag"
      local name_hl = is_sel and "ProfileNameSel" or "ProfileTag"

      -- ícone ASCII grande
      for _, icon_line in ipairs(p.icon) do
        local padded = "    " .. icon_line
        push(padded, {
          { group = icon_color, col_start = 4, col_end = #padded },
        })
      end

      push("")

      -- indicador de seleção + nome
      local prefix = is_sel and "  ▶  " or "     "
      local name_line = prefix .. p.name
      push(name_line, {
        { group = name_hl, col_start = 0, col_end = #name_line },
      })

      -- tags
      local tag_line = "       " .. table.concat(p.tags, "  ·  ")
      push(tag_line, {
        { group = tag_color, col_start = 0, col_end = #tag_line },
      })

      -- hint
      local hint = is_sel and "       [Enter] to confirm" or "       [" .. i .. "] to select"
      push(hint, {
        { group = "ProfileHint", col_start = 0, col_end = #hint },
      })

      push("")

      if i < #profiles then
        push("  " .. string.rep("─", width - 4), {
          { group = "ProfileDim", col_start = 0, col_end = 999 },
        })
        push("")
      end
    end

    push("  " .. string.rep("─", width - 4), {
      { group = "ProfileDim", col_start = 0, col_end = 999 },
    })
    push("  [j/k] navigate  ·  [Enter] confirm  ·  [q] cancel", {
      { group = "ProfileHint", col_start = 0, col_end = 999 },
    })
    push("")

    return lines, hl_regions
  end

  local selected = 1

  local function render()
    local lines, regions = build_lines(selected)
    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    local ns = vim.api.nvim_create_namespace("NvimProfileHL")
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for lnum, row_regions in ipairs(regions) do
      for _, r in ipairs(row_regions) do
        vim.api.nvim_buf_add_highlight(buf, ns, r.group, lnum - 1, r.col_start, r.col_end)
      end
    end
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  end

  render()

  local map_opts = { buffer = buf, nowait = true, silent = true }

  vim.keymap.set("n", "j", function()
    selected = selected < #profiles and selected + 1 or 1
    render()
  end, map_opts)

  vim.keymap.set("n", "k", function()
    selected = selected > 1 and selected - 1 or #profiles
    render()
  end, map_opts)

  for i = 1, #profiles do
    vim.keymap.set("n", tostring(i), function()
      selected = i
      render()
    end, map_opts)
  end

  vim.keymap.set("n", "<CR>", function()
    local choice = profiles[selected].id
    vim.api.nvim_win_close(win, true)
    callback(choice)
  end, map_opts)

  local function close_cancel()
    vim.api.nvim_win_close(win, true)
    callback("typescript")
  end

  vim.keymap.set("n", "q", close_cancel, map_opts)
  vim.keymap.set("n", "<Esc>", close_cancel, map_opts)
  vim.keymap.set("n", "<C-c>", close_cancel, map_opts)
end

-- ── Fluxo principal ───────────────────────────────────────────
local profile = read_profile()

if profile then
  vim.g.nvim_profile = profile
else
  vim.g.nvim_profile = "typescript" -- fallback enquanto seletor não fecha

  vim.schedule(function()
    open_selector(function(choice)
      save_profile(choice)
      vim.g.nvim_profile = choice
      vim.notify("Profile '" .. choice .. "' saved. Restarting...", vim.log.levels.INFO)
      vim.defer_fn(function()
        vim.cmd("silent! wa")
        vim.cmd("Lazy load all")
      end, 300)
    end)
  end)
end

-- ── Comandos utilitários ──────────────────────────────────────
vim.api.nvim_create_user_command("ProfileReset", function()
  os.remove(profile_file)
  vim.notify("Profile reset. Restart nvim to select again.", vim.log.levels.WARN)
end, { desc = "Reset nvim profile selection" })

vim.api.nvim_create_user_command("ProfileShow", function()
  vim.notify("Current profile: " .. (vim.g.nvim_profile or "none"), vim.log.levels.INFO)
end, { desc = "Show current nvim profile" })

vim.api.nvim_create_user_command("ProfileSelect", function()
  open_selector(function(choice)
    save_profile(choice)
    vim.g.nvim_profile = choice
    vim.notify("Profile changed to '" .. choice .. "'. Restart nvim to apply.", vim.log.levels.INFO)
  end)
end, { desc = "Open profile selector" })

-- ============================================================
-- BOOTSTRAP lazy.nvim
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("config.options")
require("config.keymaps")
require("config.lazy")

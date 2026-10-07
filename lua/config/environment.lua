local M = {}

local function has_executable(name)
  return vim.fn.executable(name) == 1
end

local function has_clangd()
  if has_executable("clangd") then
    return true
  end

  local suffix = vim.fn.has("win32") == 1 and ".cmd" or ""
  local mason_clangd = vim.fn.stdpath("data") .. "/mason/bin/clangd" .. suffix
  return vim.fn.executable(mason_clangd) == 1
end

local function missing_treesitter_parsers()
  local languages = {
    "c", "cpp", "lua", "vim", "vimdoc",
    "markdown", "markdown_inline", "python", "json", "html", "xml",
  }
  local missing = {}

  for _, language in ipairs(languages) do
    local parsers = vim.api.nvim_get_runtime_file("parser/" .. language .. ".*", false)
    if #parsers == 0 then
      table.insert(missing, language)
    end
  end
  return missing
end

function M.check(notify_success)
  local missing = {}

  if not has_executable("git") then
    table.insert(missing, "Git（插件安裝與版本控制）")
  end
  if not has_executable("gcc") then
    table.insert(missing, "GCC（Tree-sitter parser 編譯及 C/C++ 工具鏈）")
  end
  local missing_parsers = missing_treesitter_parsers()
  if #missing_parsers > 0 then
    table.insert(missing, "Tree-sitter parser（" .. table.concat(missing_parsers, ", ") .. "）")
    if not has_executable("tree-sitter") then
      table.insert(missing, "Tree-sitter CLI（安裝缺少的 parser）")
    end
  end
  if not has_clangd() then
    table.insert(missing, "LLVM clangd（C/C++ 語言伺服器；可執行 :MasonInstall clangd）")
  end

  if #missing > 0 then
    vim.notify(
      "環境缺少以下依賴：\n- " .. table.concat(missing, "\n- "),
      vim.log.levels.WARN,
      { title = "Neovim 環境檢查" }
    )
    return missing
  end

  if notify_success then
    vim.notify("Git、GCC 與 clangd 可使用；Tree-sitter 所需 parser 均已就緒", vim.log.levels.INFO, {
      title = "Neovim 環境檢查",
    })
  end
  return missing
end

function M.setup()
  if vim.fn.exists(":NvimCheckEnv") == 2 then
    vim.api.nvim_del_user_command("NvimCheckEnv")
  end
  vim.api.nvim_create_user_command("NvimCheckEnv", M.check, {
    desc = "檢查 Neovim 外部環境依賴",
  })

  local group = vim.api.nvim_create_augroup("UserEnvironmentCheck", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    once = true,
    callback = function()
      M.check(false)
    end,
    desc = "啟動時檢查 Neovim 外部環境依賴",
  })
end

return M

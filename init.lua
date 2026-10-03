-- ============================================================================
-- 1. 自動下載並載入 lazy.nvim 套件管理器
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Tell Tree-sitter's parser builder to use MinGW GCC instead of the unavailable MSVC cl.exe.
if vim.fn.has("win32") == 1 then
  local gcc_path = vim.fn.exepath("gcc")
  if gcc_path ~= "" then
    vim.env.CC = gcc_path
  end
end

-- ============================================================================
-- 編輯器預設值與快捷鍵。
require("config.editor")

-- 套件規格與外觀設定。
require("lazy").setup(require("config.plugins"))
require("config.appearance")

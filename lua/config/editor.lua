-- 2. 基礎 Vim 設定 & 快捷鍵
-- ============================================================================
vim.g.mapleader = " "          -- 設定 Leader 鍵為空白鍵
vim.g.maplocalleader = " "

-- 彩虹括號依巢狀層級輪流使用這些 highlight 群組。
local rainbow_highlights = {
  "RainbowDelimiterBlue",
  "RainbowDelimiterViolet",
  "RainbowDelimiterCyan",
}
vim.g.rainbow_delimiters = { highlight = rainbow_highlights }

-- 自訂彩虹括號顏色；換主題時重新套用，避免被主題覆蓋。
local function set_rainbow_highlights()
  vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = "#ea00ff", nocombine = true })
  vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#0081f9", nocombine = true })
  vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = "#4cc904", nocombine = true })
end

set_rainbow_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserRainbowHighlights", { clear = true }),
  callback = set_rainbow_highlights,
})

-- ============================================================================
-- 右鍵選單自訂 (Right-Click PopUp Menu)
-- ============================================================================
vim.opt.mouse = "a"

-- 空白 + r：重新 source 此檔
vim.keymap.set('n', '<leader>r', function()
  local config_path = vim.fn.fnamemodify(vim.env.MYVIMRC, ':p')
  if config_path == '' then
    vim.notify('MYVIMRC is not set', vim.log.levels.WARN)
    return
  end

  vim.cmd('source ' .. vim.fn.fnameescape(config_path))
  vim.notify('init.lua 已重新載入；若 plugin 設定異動，請重開 Neovim 或執行 :Lazy sync', vim.log.levels.INFO)
end, { desc = '重新載入lua設定檔', silent = true })

-- ==========================================
-- 視窗切換與管理快捷鍵 (Window Management)
-- ==========================================
vim.keymap.set('n', '<leader>wh', '<C-w>h', { desc = '移至左側視窗' })
vim.keymap.set('n', '<leader>wj', '<C-w>j', { desc = '移至下側視窗' })
vim.keymap.set('n', '<leader>wk', '<C-w>k', { desc = '移至上側視窗' })
vim.keymap.set('n', '<leader>wl', '<C-w>l', { desc = '移至右側視窗' })

vim.keymap.set('n', '<leader>ws', '<C-w>s', { desc = '水平分割視窗' })
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = '垂直分割視窗' })
vim.keymap.set('n', '<leader>wc', '<C-w>c', { desc = '關閉當前視窗' })
vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = '關閉其他視窗' })
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = '等分所有視窗大小' })

vim.keymap.set('n', '<leader>Q', '<cmd>qa<CR>', { silent = true, desc = '退出所有視窗' })
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { silent = true, desc = '切換檔案瀏覽器' })
vim.keymap.set('n', '<leader>/', function()
  vim.cmd('botright 12split | terminal')
  vim.cmd('startinsert')
end, { desc = '開啟終端機' })

-- 格式化只交給 clangd
vim.keymap.set('n', '<leader>f', function()
  local clients = vim.lsp.get_clients({ bufnr = 0, method = 'textDocument/formatting' })
  local clangd_attached = false
  for _, client in ipairs(clients) do
    if client.name == 'clangd' then
      clangd_attached = true
      break
    end
  end

  if not clangd_attached then
    vim.notify('目前 buffer 沒有可用的 clangd 格式化服務', vim.log.levels.WARN)
    return
  end

  vim.lsp.buf.format({
    async = true,
    filter = function(client)
      return client.name == 'clangd'
    end,
    formatting_options = { tabSize = 4, insertSpaces = false },
  })
end, { desc = '格式化當前緩衝區' })

-- 編輯器外觀與縮排
vim.opt.number = true          -- 顯示行號
vim.opt.shiftwidth = 4        -- 縮排寬度 4，使用 Tab 字元
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = false     -- Tab 使用 Tab 字元
vim.opt.signcolumn = "yes"    -- 永久保留左側標記欄
vim.opt.termguicolors = true  -- 開啟 24-bit TrueColor 彩色支援
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

-- 在 Insert 模式下連按 jk 切換回 Normal 模式 (Esc)
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true, silent = true })

-- ============================================================================

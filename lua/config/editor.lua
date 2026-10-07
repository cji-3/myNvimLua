-- 2. 基礎設定與快捷鍵
-- ============================================================================
vim.g.mapleader = " "          -- 設定 Leader 鍵為空白鍵
vim.g.maplocalleader = " "

-- ============================================================================
-- 彩虹括號顏色
-- ============================================================================
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
-- 滑鼠與檔案類型設定
-- ============================================================================
vim.opt.mouse = "a"

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('UserBatchSyntax', { clear = true }),
  pattern = 'dosbatch',
  callback = function(args)
    vim.bo[args.buf].syntax = 'dosbatch'
  end,
})

-- ============================================================================
-- 設定檔熱重載
-- ============================================================================
-- 空白 + r：重新載入 init.lua 和本設定模組，避免 Lua 模組快取保留舊內容。
vim.keymap.set('n', '<leader>r', function()
  local config_path = vim.fn.fnamemodify(vim.env.MYVIMRC, ':p')
  if config_path == '' then
    vim.notify('MYVIMRC is not set', vim.log.levels.WARN)
    return
  end

  package.loaded['config.editor'] = nil
  vim.cmd('source ' .. vim.fn.fnameescape(config_path))
  vim.notify('init.lua 已重新載入；若 plugin 設定異動，請重開 Neovim 或執行 :Lazy sync', vim.log.levels.INFO)
end, { desc = '重新載入lua設定檔', silent = true })

-- ============================================================================
-- 視窗與 buffer 管理
-- ============================================================================
vim.keymap.set('n', '<leader>wh', '<C-w>h', { desc = '移至左側視窗' })
vim.keymap.set('n', '<leader>wj', '<C-w>j', { desc = '移至下側視窗' })
vim.keymap.set('n', '<leader>wk', '<C-w>k', { desc = '移至上側視窗' })
vim.keymap.set('n', '<leader>wl', '<C-w>l', { desc = '移至右側視窗' })

local last_edit_buffer
local function remember_edit_buffer(buf)
  if vim.api.nvim_buf_is_valid(buf)
      and vim.bo[buf].buftype == ''
      and vim.api.nvim_buf_get_name(buf) ~= '' then
    last_edit_buffer = buf
  end
end

remember_edit_buffer(vim.api.nvim_get_current_buf())
local editor_buffer_group = vim.api.nvim_create_augroup('UserLastEditBuffer', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
  group = editor_buffer_group,
  callback = function(args) remember_edit_buffer(args.buf) end,
})
vim.api.nvim_create_autocmd('BufWipeout', {
  group = editor_buffer_group,
  callback = function(args)
    if args.buf == last_edit_buffer then
      last_edit_buffer = nil
    end
  end,
})

vim.keymap.set('n', '<leader>wn', function()
  local api = vim.api
  local candidate = last_edit_buffer
  if not candidate
      or not api.nvim_buf_is_valid(candidate)
      or vim.bo[candidate].buftype ~= ''
      or api.nvim_buf_get_name(candidate) == '' then
    candidate = nil
  end

  if not candidate then
    local latest = -1
    for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
      local buf = info.bufnr
      if api.nvim_buf_is_valid(buf)
          and vim.bo[buf].buftype == ''
          and api.nvim_buf_get_name(buf) ~= ''
          and info.lastused > latest then
        candidate = buf
        latest = info.lastused
      end
    end
    last_edit_buffer = candidate
  end

  if not candidate then
    vim.notify('沒有可恢復的檔案編輯區；請先從檔案樹開啟檔案', vim.log.levels.WARN)
    return
  end

  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if api.nvim_win_get_buf(win) == candidate then
      api.nvim_set_current_win(win)
      return
    end
  end

  local current_buf = api.nvim_get_current_buf()
  if vim.bo[current_buf].filetype == 'NvimTree' then
    vim.cmd('rightbelow vertical sbuffer ' .. candidate)
    for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
      if vim.bo[api.nvim_win_get_buf(win)].filetype == 'NvimTree' then
        api.nvim_win_set_width(win, 30)
        break
      end
    end
  else
    api.nvim_win_set_buf(0, candidate)
  end
end, { desc = '恢復最近的檔案編輯區' })

-- 分割視窗、關閉 buffer 與視窗配置。
vim.keymap.set('n', '<leader>ws', '<C-w>s', { desc = '水平分割視窗' })
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = '垂直分割視窗' })
local function close_current_file(force)
  local api = vim.api
  local current_buf = api.nvim_get_current_buf()
  local current_win = api.nvim_get_current_win()

  if vim.bo[current_buf].buftype ~= '' or api.nvim_buf_get_name(current_buf) == '' then
    vim.notify('目前視窗不是一般檔案，沒有可關閉的檔案', vim.log.levels.WARN)
    return
  end

  if vim.bo[current_buf].modified and not force then
    vim.notify('目前檔案尚未儲存，請先儲存或放棄變更', vim.log.levels.WARN)
    return
  end

  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  local current_index = 0
  for index, info in ipairs(buffers) do
    if info.bufnr == current_buf then
      current_index = index
      break
    end
  end

  local replacement
  for offset = 1, #buffers do
    local index = ((current_index + offset - 1) % #buffers) + 1
    local candidate = buffers[index].bufnr
    if candidate ~= current_buf
        and vim.api.nvim_buf_is_valid(candidate)
        and vim.bo[candidate].buftype == ''
        and vim.api.nvim_buf_get_name(candidate) ~= '' then
      replacement = candidate
      break
    end
  end

  if not replacement then
    replacement = api.nvim_create_buf(true, false)
  end

  api.nvim_win_set_buf(current_win, replacement)
  api.nvim_buf_delete(current_buf, { force = force })
end

vim.keymap.set('n', '<leader>wc', function()
  close_current_file(false)
end, { desc = '安全關閉目前檔案' })
vim.keymap.set('n', '<leader>wC', function()
  close_current_file(true)
end, { desc = '強制關閉目前檔案並丟棄未儲存變更' })
vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = '關閉其他視窗' })
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = '等分所有視窗大小' })

-- ============================================================================
-- 檔案樹、Git 與終端機
-- ============================================================================
vim.keymap.set('n', '<leader>Q', '<cmd>qa<CR>', { silent = true, desc = '退出所有視窗' })
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { silent = true, desc = '切換檔案瀏覽器' })
vim.keymap.set('n', '<leader>gs', '<cmd>Git<CR>', { desc = 'Git 狀態' })
vim.keymap.set('n', '<leader>gd', '<cmd>Git diff<CR>', { desc = 'Git 差異' })
vim.keymap.set('n', '<leader>ga', '<cmd>Gwrite<CR>', { desc = '加入目前檔案至暫存' })
vim.keymap.set('n', '<leader>gc', '<cmd>Git commit<CR>', { desc = '提交 Git 變更' })
vim.keymap.set('n', '<leader>gf', '<cmd>Git fetch<CR>', { desc = '取得遠端 Git 更新' })
vim.keymap.set('n', '<leader>gl', '<cmd>Git pull<CR>', { desc = '拉取遠端 Git 更新' })
vim.keymap.set('n', '<leader>gp', '<cmd>Git push<CR>', { desc = '推送 Git 變更' })
vim.keymap.set('n', '<leader>/', function()
  vim.cmd('botright 12split | terminal')
  vim.cmd('startinsert')
end, { desc = '開啟終端機' })

vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('UserTerminalMappings', { clear = true }),
  callback = function(args)
    vim.keymap.set('t', '<C-q>', function()
      if vim.api.nvim_buf_is_valid(args.buf) then
        vim.api.nvim_buf_delete(args.buf, { force = true })
      end
    end, { buffer = args.buf, desc = '關閉並結束終端機程序' })
  end,
})

-- ============================================================================
-- LSP 與程式碼格式化
-- ============================================================================
-- 格式化只交給 clangd。
vim.keymap.set('n', '<leader>nh', '<cmd>nohlsearch<CR>', {
  desc = '清除搜尋反白',
  silent = true,
})

vim.keymap.set('n', '<leader>cf', function()
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

-- ============================================================================
-- C/C++：清理游標附近多餘的右括號
-- ============================================================================
-- 取得整個 buffer，建立每行在串接字串中的起始位置（Lua 字串索引從 1 開始）。
vim.keymap.set('n', '<leader>z', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  if filetype ~= 'c' and filetype ~= 'cpp' and filetype ~= 'objc' and filetype ~= 'objcpp' then
    vim.notify('Space z 目前只支援 C/C++ 檔案', vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local source = table.concat(lines, '\n')
  local line_starts = {}
  local offset = 1
  for index, line in ipairs(lines) do
    line_starts[index] = offset
    offset = offset + #line + 1
  end

  local stack = {}
  local bracket_pairs = {}
  local unmatched_closers = {}
  local index = 1

  -- 掃描括號結構；註解和字串中的括號不參與配對。
  while index <= #source do
    local char = source:sub(index, index)
    local next_char = source:sub(index + 1, index + 1)

    if char == '/' and next_char == '/' then
      local newline = source:find('\n', index + 2, true)
      index = newline or (#source + 1)
    elseif char == '/' and next_char == '*' then
      local comment_end = source:find('*/', index + 2, true)
      index = comment_end and (comment_end + 2) or (#source + 1)
    elseif char == 'R' and next_char == '"' then
      local delimiter_end = source:find('(', index + 2, true)
      local delimiter = delimiter_end and source:sub(index + 2, delimiter_end - 1)
      local raw_end = delimiter and source:find(')' .. delimiter .. '"', delimiter_end + 1, true)
      index = raw_end and (raw_end + #delimiter + 2) or (#source + 1)
    elseif char == '"' or char == "'" then
      local quote = char
      index = index + 1
      while index <= #source do
        char = source:sub(index, index)
        if char == '\\' then
          index = index + 2
        elseif char == quote then
          index = index + 1
          break
        else
          index = index + 1
        end
      end
    elseif char == '(' or char == '{' then
      stack[#stack + 1] = { char = char, pos = index }
      index = index + 1
    elseif char == ')' or char == '}' then
      local opener = char == ')' and '(' or '{'
      local top = stack[#stack]
      if top and top.char == opener then
        stack[#stack] = nil
        bracket_pairs[#bracket_pairs + 1] = { open = top.pos, close = index }
      else
        unmatched_closers[index] = true
      end
      index = index + 1
    else
      index = index + 1
    end
  end

  -- 游標必須嚴格位於已配對括號之間，不能只是在括號外觀附近。
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_pos = line_starts[cursor[1]] + cursor[2]
  local inside_pair = false
  for _, pair in ipairs(bracket_pairs) do
    if pair.open < cursor_pos and cursor_pos < pair.close then
      inside_pair = true
      break
    end
  end

  if not inside_pair then
    vim.notify('游標不在成對的括號內，未修改內容', vim.log.levels.INFO)
    return
  end

  local row = cursor[1]
  local line = lines[row]
  local remove_col
  local closest_distance
  local line_end = line_starts[row] + #line

  -- 若游標所在配對後面有同類多餘閉括號，移除原配對的閉括號，
  -- 讓後方的括號接替配對；否則從本行不成對的閉括號中挑最近者。
  for _, pair in ipairs(bracket_pairs) do
    local opener = source:sub(pair.open, pair.open)
    local closer = opener == '(' and ')' or '}'
    if pair.open < cursor_pos
        and cursor_pos < pair.close
        and pair.close >= line_starts[row]
        and pair.close < line_end then
      for pos in pairs(unmatched_closers) do
        if pos > pair.close and pos < line_end and source:sub(pos, pos) == closer then
          local col = pair.close - line_starts[row] + 1
          local distance = math.abs((col - 1) - cursor[2])
          if not closest_distance or distance < closest_distance then
            remove_col = col
            closest_distance = distance
          end
          break
        end
      end
    end
  end

  for pos in pairs(unmatched_closers) do
    if not remove_col and pos >= line_starts[row] and pos < line_end then
      local col = pos - line_starts[row] + 1
      local distance = math.abs((col - 1) - cursor[2])
      if not closest_distance or distance < closest_distance then
        remove_col = col
        closest_distance = distance
      end
    end
  end
  if not remove_col then
    vim.notify('目前行沒有不成對的 ) 或 }', vim.log.levels.INFO)
    return
  end

  -- 以新字串取代目前行，並將游標欄位同步往左修正。
  local updated = {}
  local new_cursor_col = cursor[2] - (remove_col <= cursor[2] and 1 or 0)
  for col = 1, #line do
    if col ~= remove_col then
      updated[#updated + 1] = line:sub(col, col)
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { table.concat(updated) })
  vim.api.nvim_win_set_cursor(0, { cursor[1], math.max(0, new_cursor_col) })
  vim.notify(('已移除距游標最近的 %s'):format(line:sub(remove_col, remove_col)), vim.log.levels.INFO)
end, { desc = '清理游標附近多餘括號' })

-- ============================================================================
-- 編輯器外觀與縮排
-- ============================================================================
vim.opt.number = true          -- 顯示行號
vim.opt.relativenumber = true  -- 顯示相對行號，方便使用數字搭配移動命令
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

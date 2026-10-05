local M = {}

local tags = {
  { name = "brief", detail = "簡短說明" },
  { name = "details", detail = "詳細說明" },
  { name = "version", detail = "版本資訊" },
  { name = "date", detail = "日期" },
  { name = "copyright", detail = "版權資訊" },
  { name = "param", detail = "函式參數" },
  { name = "tparam", detail = "樣板參數" },
  { name = "return", detail = "回傳值" },
  { name = "retval", detail = "回傳值說明" },
  { name = "exception", detail = "可能拋出的例外" },
  { name = "throws", detail = "可能拋出的例外" },
  { name = "throw", detail = "可能拋出的例外" },
  { name = "pre", detail = "前置條件" },
  { name = "post", detail = "後置條件" },
  { name = "invariant", detail = "不變條件" },
  { name = "attention", detail = "注意事項" },
  { name = "note", detail = "注意事項" },
  { name = "warning", detail = "警告" },
  { name = "deprecated", detail = "已棄用" },
  { name = "see", detail = "參考資料" },
  { name = "since", detail = "引入版本" },
  { name = "author", detail = "作者" },
  { name = "file", detail = "檔案說明" },
  { name = "todo", detail = "待辦事項" },
  { name = "bug", detail = "問題說明" },
  { name = "par", detail = "段落說明" },
  { name = "section", detail = "章節標題" },
  { name = "subsection", detail = "子章節標題" },
  { name = "subsubsection", detail = "次級子章節標題" },
  { name = "ref", detail = "交叉參照" },
  { name = "class", detail = "類別說明" },
  { name = "struct", detail = "結構說明" },
  { name = "enum", detail = "列舉說明" },
  { name = "typedef", detail = "型別定義說明" },
  { name = "namespace", detail = "命名空間說明" },
  { name = "example", detail = "範例" },
  { name = "code", detail = "程式碼區塊" },
  { name = "endcode", detail = "程式碼區塊結束" },
  { name = "mainpage", detail = "首頁說明" },
  { name = "page", detail = "頁面說明" },
  { name = "defgroup", detail = "定義文件群組" },
  { name = "overload", detail = "多載函式說明" },
  { name = "addindex", detail = "索引項目" },
  { name = "anchor", detail = "文件錨點" },
  { name = "arg", detail = "函式參數說明" },
  { name = "callgraph", detail = "呼叫關係圖" },
  { name = "callergraph", detail = "被呼叫關係圖" },
  { name = "cond", detail = "條件文件區塊" },
  { name = "copydoc", detail = "複製其他文件" },
  { name = "dir", detail = "目錄說明" },
  { name = "endcond", detail = "條件文件區塊結束" },
  { name = "f", detail = "數學公式" },
  { name = "htmlonly", detail = "HTML 專用內容" },
  { name = "image", detail = "插入圖片" },
  { name = "include", detail = "插入程式碼檔案" },
  { name = "interface", detail = "介面說明" },
  { name = "li", detail = "清單項目" },
  { name = "link", detail = "文件連結" },
  { name = "memberof", detail = "成員所屬類別" },
  { name = "package", detail = "套件說明" },
  { name = "property", detail = "屬性說明" },
  { name = "protocol", detail = "協定說明" },
  { name = "related", detail = "相關文件" },
  { name = "relates", detail = "關聯文件" },
  { name = "remark", detail = "備註" },
  { name = "showinitializer", detail = "顯示初始化內容" },
  { name = "snippet", detail = "插入程式碼片段" },
  { name = "snippetdoc", detail = "插入程式碼片段文件" },
  { name = "startuml", detail = "UML 圖表區塊" },
  { name = "endlink", detail = "文件連結結束" },
  { name = "endhtmlonly", detail = "HTML 專用內容結束" },
  { name = "verbatim", detail = "原樣顯示內容" },
  { name = "endverbatim", detail = "原樣顯示內容結束" },
}

local tag_names = {}
for _, tag in ipairs(tags) do
  tag_names[tag.name] = true
end

local namespace = vim.api.nvim_create_namespace("doxygen_tags")
local queries = {}
local scheduled = {}
local parser_warnings = {}

local function language_for_buffer(bufnr)
  local filetype = vim.bo[bufnr].filetype
  if filetype == "c" or filetype == "cpp" then
    return filetype
  end
end

local function get_comment_query(language)
  if not queries[language] then
    queries[language] = vim.treesitter.query.parse(language, "(comment) @comment")
  end
  return queries[language]
end

local function get_comment_parser(bufnr)
  local language = language_for_buffer(bufnr)
  if not language then
    return
  end

  local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr, language)
  if not parser_ok then
    if not parser_warnings[bufnr] then
      parser_warnings[bufnr] = true
      vim.notify("Doxygen 標籤補全與高亮需要可用的 C/C++ Tree-sitter parser：" .. tostring(parser), vim.log.levels.WARN)
    end
    return
  end

  local parse_ok, trees = pcall(parser.parse, parser)
  if not parse_ok then
    if not parser_warnings[bufnr] then
      parser_warnings[bufnr] = true
      vim.notify("解析 C/C++ 註解失敗，無法套用 Doxygen 標籤高亮：" .. tostring(trees), vim.log.levels.WARN)
    end
    return
  end

  return trees, get_comment_query(language)
end

local function cursor_is_in_comment(bufnr)
  local trees, query = get_comment_parser(bufnr)
  if not trees then
    return false
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor[1] - 1
  local cursor_col = cursor[2]

  for _, tree in ipairs(trees) do
    for _, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
      local start_row, start_col, end_row, end_col = node:range()
      if cursor_row >= start_row and cursor_row <= end_row
          and (cursor_row > start_row or cursor_col >= start_col)
          and (cursor_row < end_row or cursor_col <= end_col) then
        return true
      end
    end
  end
  return false
end

local function each_doxygen_tag(bufnr, callback)
  local trees, query = get_comment_parser(bufnr)
  if not trees then
    return false
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for _, tree in ipairs(trees) do
    for _, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
      local start_row, start_col, end_row, end_col = node:range()
      for row = start_row, end_row do
        local line = lines[row + 1]
        if line then
          local first_col = row == start_row and start_col or 0
          local last_col = row == end_row and end_col or #line
          local search_col = first_col + 1
          while search_col <= last_col do
            local first, last = line:find("[\\@][%a]+", search_col)
            if not first or last > last_col then
              break
            end

            local tag_name = line:sub(first + 1, last)
            if tag_names[tag_name] then
              callback(row, first - 1, last)
            end
            search_col = last + 1
          end
        end
      end
    end
  end

  return true
end

local function add_syntax_fallback(bufnr)
  if vim.bo[bufnr].syntax == "" then
    return
  end

  for row, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    local search_col = 1
    while search_col <= #line do
      local first, last = line:find("[\\@][%a]+", search_col)
      if not first then
        break
      end

      local tag_name = line:sub(first + 1, last)
      local group = vim.fn.synIDattr(vim.fn.synID(row, first, 1), "name")
      if tag_names[tag_name] and group == "DoxygenTag" then
        vim.api.nvim_buf_set_extmark(bufnr, namespace, row - 1, first - 1, {
          end_col = last,
          hl_group = "DoxygenTag",
          priority = 200,
        })
      end
      search_col = last + 1
    end
  end
end

local function refresh_highlights(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  local parser_available = each_doxygen_tag(bufnr, function(row, start_col, end_col)
    vim.api.nvim_buf_set_extmark(bufnr, namespace, row, start_col, {
      end_col = end_col,
      hl_group = "DoxygenTag",
      priority = 200,
    })
  end)

  if not parser_available then
    add_syntax_fallback(bufnr)
  end
end

local function schedule_highlights(bufnr)
  if scheduled[bufnr] then
    scheduled[bufnr] = scheduled[bufnr] + 1
  else
    scheduled[bufnr] = 1
  end
  local generation = scheduled[bufnr]

  vim.defer_fn(function()
    if scheduled[bufnr] ~= generation then
      return
    end
    scheduled[bufnr] = nil
    refresh_highlights(bufnr)
  end, 80)
end

function M.setup_highlighting()
  local group = vim.api.nvim_create_augroup("UserDoxygenHighlights", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost", "FileType", "TextChanged", "TextChangedI" }, {
    group = group,
    callback = function(args)
      schedule_highlights(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    callback = function(args)
      scheduled[args.buf] = nil
      parser_warnings[args.buf] = nil
    end,
  })

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      schedule_highlights(bufnr)
    end
  end
end

function M.setup_completion(cmp)
  cmp.register_source("doxygen", {
    get_trigger_characters = function()
      return { "\\" }
    end,
    get_keyword_pattern = function()
      return [[\\\w*]]
    end,
    is_available = function()
      return cursor_is_in_comment(vim.api.nvim_get_current_buf())
    end,
    complete = function(_, _, callback)
      local items = {}
      for _, tag in ipairs(tags) do
        items[#items + 1] = {
          label = "\\" .. tag.name,
          detail = tag.detail,
          insertText = "\\" .. tag.name,
        }
      end
      callback({ items = items, isIncomplete = false })
    end,
  })
end

return M

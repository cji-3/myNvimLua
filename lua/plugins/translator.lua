-- Bing 翻譯與命名風格替換套件。
return {
    "voldikss/vim-translator",
    config = function()
      vim.g.translator_target_lang = "zh-TW"
      vim.g.translator_default_engines = { "bing" }
      vim.g.translator_window_type = "popup"
      vim.g.translator_window_max_width = 0.6
      vim.g.translator_window_max_height = 0.6

      --------------------------------------------------------------------------
      -- URL Encode 與字串處理
      --------------------------------------------------------------------------
      local function url_encode(str)
        if str then
          str = str:gsub("\n", "\r\n")
          str = str:gsub("([^%w %-%_%.%~])", function(c)
            return string.format("%%%02X", string.byte(c))
          end)
          str = str:gsub(" ", "%%20")
        end
        return str
      end

      local function format_text(raw_text, style)
        if style == "raw" then return raw_text end

        local words = {}
        for w in raw_text:gmatch("[%w]+") do
          table.insert(words, w:lower())
        end

        if #words == 0 then return raw_text end

        if style == "snake" then
          return table.concat(words, "_")
        elseif style == "upper_snake" then
          return table.concat(words, "_"):upper()
        elseif style == "camel" then
          local formatted = words[1]
          for i = 2, #words do
            formatted = formatted .. words[i]:gsub("^%l", string.upper)
          end
          return formatted
        elseif style == "pascal" then
          local formatted = ""
          for i = 1, #words do
            formatted = formatted .. words[i]:gsub("^%l", string.upper)
          end
          return formatted
        elseif style == "space" then
          return table.concat(words, " ")
        end
        return raw_text
      end

      local function report_error(message)
        vim.notify(message, vim.log.levels.ERROR, { title = "Bing 翻譯" })
      end

      local function translate_with_bing(text, target_lang, callback)
        vim.system({ "curl", "-fsSL", "--max-time", "20", "https://www.bing.com/translator" }, {
          text = true,
        }, function(page_result)
          vim.schedule(function()
            if page_result.code ~= 0 then
              report_error("無法載入 Bing 翻譯頁面：" .. (page_result.stderr or "curl 失敗"))
              return
            end

            local ig = page_result.stdout:match('"ig"%s*:%s*"([^"]+)"')
            local iid = page_result.stdout:match('id="rich_tta" data%-iid="([^"]+)"')
            local timestamp, token = page_result.stdout:match(
              'params_AbusePreventionHelper%s*=%s*%[(%d+),"([^"]+)",%d+%]'
            )
            if not (ig and iid and timestamp and token) then
              report_error("無法從 Bing 頁面取得翻譯所需的暫時參數")
              return
            end

            local bing_lang = target_lang == "zh-TW" and "zh-Hant" or target_lang
            local url = "https://www.bing.com/ttranslatev3?isVertical=1&IG="
              .. url_encode(ig) .. "&IID=" .. url_encode(iid)
            local body = "fromLang=auto-detect&to=" .. url_encode(bing_lang)
              .. "&text=" .. url_encode(text)
              .. "&token=" .. url_encode(token) .. "&key=" .. timestamp

            vim.system({
              "curl", "-sS", "--max-time", "20", "-X", "POST",
              "-A", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
              "-H", "Content-Type: application/x-www-form-urlencoded",
              "--data-raw", body, "-w", "\n%{http_code}", url,
            }, { text = true }, function(result)
              vim.schedule(function()
                if result.code ~= 0 then
                  report_error("Bing 翻譯連線失敗：" .. (result.stderr or "curl 失敗"))
                  return
                end

                local response, status = (result.stdout or ""):match("^(.*)\n(%d%d%d)%s*$")
                if not status or status:sub(1, 1) ~= "2" then
                  report_error("Bing 翻譯回應 HTTP " .. (status or "未知狀態"))
                  return
                end

                local ok, decoded = pcall(vim.json.decode, response)
                if not ok or type(decoded) ~= "table" or type(decoded[1]) ~= "table"
                    or type(decoded[1].translations) ~= "table" then
                  report_error("無法解析 Bing 翻譯結果")
                  return
                end

                local translated = {}
                for _, item in ipairs(decoded[1].translations) do
                  if type(item.text) == "string" then
                    table.insert(translated, item.text)
                  end
                end
                local translated_text = table.concat(translated)
                if translated_text == "" then
                  report_error("Bing 沒有回傳翻譯內容")
                  return
                end
                callback(translated_text)
              end)
            end)
          end)
        end)
      end

      local function get_source_text()
        local mode = vim.fn.mode()
        local bufnr = vim.api.nvim_get_current_buf()
        if mode:sub(1, 1) == "n" then
          local word = vim.fn.expand("<cword>")
          if word == "" then return nil end
          return word
        end

        vim.cmd("normal! \27")
        local s_pos = vim.api.nvim_buf_get_mark(bufnr, "<")
        local e_pos = vim.api.nvim_buf_get_mark(bufnr, ">")
        if s_pos[1] == 0 or e_pos[1] == 0 then return nil end

        local start_line = s_pos[1] - 1
        local start_col = s_pos[2]
        local end_line = e_pos[1] - 1
        local end_text = vim.api.nvim_buf_get_lines(bufnr, end_line, end_line + 1, false)[1]
        local end_col = vim.fn.byteidx(end_text, vim.fn.charidx(end_text, e_pos[2]) + 1)
        if end_col < 0 then end_col = #end_text end
        local lines = vim.api.nvim_buf_get_text(bufnr, start_line, start_col, end_line, end_col, {})
        local text = table.concat(lines, "\n"):gsub("^%s*(.-)%s*$", "%1")
        if text == "" then return nil end
        return text, { bufnr, start_line, start_col, end_line, end_col }
      end

      local function show_translation(text, popup, direction)
        if not popup then
          vim.notify(text, vim.log.levels.INFO, { title = direction })
          return
        end

        local lines = vim.split(text, "\n", { plain = true })
        local max_width = math.max(1, math.floor(vim.o.columns * 0.6) - 2)
        local max_height = math.max(1, math.min(
          math.floor(vim.o.lines * 0.4) - 2,
          vim.o.lines - vim.fn.screenrow() - 2
        ))
        local widest_line = 0
        for _, line in ipairs(lines) do
          widest_line = math.max(widest_line, vim.fn.strdisplaywidth(line))
        end
        local width = math.min(math.max(1, widest_line), max_width)
        local content_height = 0
        for _, line in ipairs(lines) do
          content_height = content_height + math.max(1, math.ceil(vim.fn.strdisplaywidth(line) / width))
        end
        local height = math.min(content_height, max_height)
        local col = math.min(0, vim.o.columns - vim.fn.screencol() - width - 2)
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].bufhidden = "wipe"
        local win = vim.api.nvim_open_win(buf, true, {
          relative = "cursor",
          row = 1,
          col = col,
          width = width,
          height = height,
          style = "minimal",
          border = "rounded",
          title = " " .. direction .. " ",
          title_pos = "center",
        })
        vim.wo[win].wrap = true
        vim.wo[win].linebreak = true
        for _, key in ipairs({ "q", "<Esc>", "<CR>" }) do
          vim.keymap.set("n", key, function()
            if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
          end, { buffer = buf, silent = true, nowait = true })
        end
      end

      local function translate_selection(target_lang, popup)
        local text = get_source_text()
        if not text then
          vim.notify("請先選取文字，或將游標放在要翻譯的單字上", vim.log.levels.WARN, { title = "Bing 翻譯" })
          return
        end
        vim.notify("翻譯中...", vim.log.levels.INFO, { title = "Bing 翻譯" })
        translate_with_bing(text, target_lang, function(translated)
          local direction = target_lang == "en" and "中翻英" or "英翻中"
          show_translation(translated, popup, direction)
        end)
      end

      local function custom_replace(target_lang, style)
        local text, range = get_source_text()
        if not text or not range then
          vim.notify("請先選取要翻譯並替換的文字", vim.log.levels.WARN, { title = "Bing 翻譯" })
          return
        end

        vim.notify("翻譯中...", vim.log.levels.INFO, { title = "Bing 翻譯" })
        translate_with_bing(text, target_lang, function(translated)
          local final_text = format_text(translated, style)
          local bufnr, start_line, start_col, end_line, end_col = unpack(range)
          if not vim.api.nvim_buf_is_valid(bufnr) then
            report_error("原始緩衝區已關閉，未能替換翻譯")
            return
          end
          vim.api.nvim_buf_set_text(bufnr, start_line, start_col, end_line, end_col, { final_text })
          vim.notify("翻譯完成: " .. final_text, vim.log.levels.INFO, { title = "Bing 翻譯" })
        end)
      end

      --------------------------------------------------------------------------
      -- 快捷鍵綁定
      --------------------------------------------------------------------------
      local opts = { silent = true, noremap = true }

      vim.keymap.set({ "n", "v" }, "<leader>te", function() translate_selection("en", true) end, vim.tbl_extend("force", opts, { desc = "中翻英 (Bing 彈窗)" }))
      vim.keymap.set({ "n", "v" }, "<leader>tz", function() translate_selection("zh-TW", true) end, vim.tbl_extend("force", opts, { desc = "英翻中 (Bing 彈窗)" }))
      vim.keymap.set({ "n", "v" }, "<leader>tse", function() translate_selection("en", false) end, vim.tbl_extend("force", opts, { desc = "中翻英 (Bing 通知)" }))
      vim.keymap.set({ "n", "v" }, "<leader>tsz", function() translate_selection("zh-TW", false) end, vim.tbl_extend("force", opts, { desc = "英翻中 (Bing 通知)" }))

      vim.keymap.set("v", "<leader>tte", function() custom_replace("en", "snake") end, vim.tbl_extend("force", opts, { desc = "中翻英覆蓋 (底線小分詞)" }))
      vim.keymap.set("v", "<leader>tTE", function() custom_replace("en", "upper_snake") end, vim.tbl_extend("force", opts, { desc = "中翻英覆蓋 (常量底線)" }))
      vim.keymap.set("v", "<leader>ttE", function() custom_replace("en", "camel") end, vim.tbl_extend("force", opts, { desc = "中翻英覆蓋 (小駝峰)" }))
      vim.keymap.set("v", "<leader>tTe", function() custom_replace("en", "pascal") end, vim.tbl_extend("force", opts, { desc = "中翻英覆蓋 (大駝峰)" }))
      vim.keymap.set("v", "<leader>tE",  function() custom_replace("en", "space") end, vim.tbl_extend("force", opts, { desc = "中翻英覆蓋 (空格小分詞)" }))
      vim.keymap.set("v", "<leader>ttz", function() custom_replace("zh-TW", "raw") end, vim.tbl_extend("force", opts, { desc = "英翻中覆蓋" }))
    end
  }

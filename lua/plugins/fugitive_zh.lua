local api = vim.api
local namespace = api.nvim_create_namespace("fugitive_chinese_sections")
local section_names = {
  Untracked = { text = "未追蹤", group = "fugitiveUntrackedHeading" },
  Unstaged = { text = "未暫存", group = "fugitiveUnstagedHeading" },
  Staged = { text = "已暫存", group = "fugitiveStagedHeading" },
}

local function render(bufnr)
  if not api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "fugitive" then
    return
  end

  api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for row, line in ipairs(lines) do
    local heading = line:match("^(%a+)%s+%(")
    local translation = section_names[heading]
    if translation then
      local width = vim.fn.strdisplaywidth(heading)
      local padding = string.rep(" ", math.max(0, width - vim.fn.strdisplaywidth(translation.text)))
      api.nvim_buf_set_extmark(bufnr, namespace, row - 1, 0, {
        virt_text = { { translation.text .. padding, translation.group } },
        virt_text_pos = "overlay",
        hl_mode = "replace",
      })
    end
  end
end

local group = api.nvim_create_augroup("FugitiveChineseSections", { clear = true })
api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "fugitive",
  callback = function(args)
    render(args.buf)
    api.nvim_buf_attach(args.buf, false, {
      on_lines = function(_, bufnr)
        vim.schedule(function()
          render(bufnr)
        end)
      end,
    })
  end,
})

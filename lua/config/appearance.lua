-- Diagnostic 提示設定
vim.diagnostic.config({
  update_in_insert = false,
})

-- ============================================================================
-- 4. 透明背景設定
-- ============================================================================
local function set_transparent_bg()
  local transparent_ui_groups = {
    "Normal", "NormalNC", "LineNr", "Folded", "NonText",
    "SignColumn", "StatusLine", "StatusLineNC", "EndOfBuffer",
    "NvimTreeNormal", "NvimTreeNormalNC"
  }
  for _, group in ipairs(transparent_ui_groups) do
    vim.cmd(string.format("highlight %s guibg=NONE ctermbg=NONE", group))
  end
end

local function set_cursorline_highlight()
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE", ctermbg = "NONE" })
end

local function set_comment_highlight()
  vim.api.nvim_set_hl(0, "Comment", { fg = "#a9b1d6", italic = true })
end

local function set_diagnostic_highlights()
  vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", {
    fg = "#c0caf5",
    nocombine = true,
  })
end

local function set_ibl_scope_highlights()
  vim.api.nvim_set_hl(0, "@ibl.scope.underline.1", {
    bold = true,
    underline = false,
    undercurl = false,
  })
end

local function set_doxygen_highlight()
  vim.api.nvim_set_hl(0, "DoxygenTag", { fg = "#e0af68", bold = true })
end

set_transparent_bg()
set_cursorline_highlight()
set_comment_highlight()
set_diagnostic_highlights()
set_ibl_scope_highlights()
set_doxygen_highlight()
require("config.doxygen").setup_highlighting()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    set_transparent_bg()
    set_cursorline_highlight()
    set_comment_highlight()
    set_diagnostic_highlights()
    set_ibl_scope_highlights()
    set_doxygen_highlight()
  end,
})
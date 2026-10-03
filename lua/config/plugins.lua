-- 由 lazy.nvim 載入的套件規格。
return {

  -- 配色主題
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },

  -- 左側檔案樹
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({ view = { width = 30 } })
      vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { silent = true })
    end
  },

  -- 新增：Telescope 模糊搜尋神器 (快速搜尋檔案、字串)
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '搜尋專案檔案' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '搜尋程式碼內容 (Grep)' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '搜尋已開啟的 Buffer' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '搜尋 Vim 說明文件' })
    end
  },

  -- 新增：Flash.nvim 光標極速跳躍 (替代傳統 f/t/方向鍵)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash 極速跳躍" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Tree-sitter 選取" },
    },
  },

  -- 新增：Gitsigns 程式碼變更提示 (列標示 + 修改預覽)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          vim.keymap.set('n', ']h', gs.next_hunk, { buffer = bufnr, desc = "下一個 Git 修改點" })
          vim.keymap.set('n', '[h', gs.prev_hunk, { buffer = bufnr, desc = "上一個 Git 修改點" })
          vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = "預覽 Git 修改內容" })
        end
      })
    end
  },

  -- 自動補全
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'path' },
        }),
        mapping = cmp.mapping.preset.insert({
          ['<C-j>'] = cmp.mapping.select_next_item(),
          ['<C-k>'] = cmp.mapping.select_prev_item(),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<C-Space>'] = cmp.mapping.complete(),
        }),
      })
    end
  },

  -- Mason 安裝 LSP
  { "williamboman/mason.nvim", config = true },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason-lspconfig").setup({
        ensure_installed = { "clangd" },
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = capabilities,
            })
          end,
          ["clangd"] = function()
            local gcc_path = vim.fn.exepath("gcc")
            local extra_args = {
              "--background-index",
              "--header-insertion=never",
              "--completion-style=detailed",
              "--extra-arg=--target=x86_64-w64-windows-gnu",
              "--fallback-style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Always}",
            }

            if gcc_path ~= "" then
              gcc_path = gcc_path:gsub("\\", "/")
              table.insert(extra_args, "--query-driver=" .. gcc_path)
            else
              table.insert(extra_args, "--query-driver=C:/Program Files/mingw64/bin/*.exe")
            end

            require("lspconfig").clangd.setup({
              capabilities = capabilities,
              cmd = vim.list_extend({ "clangd" }, extra_args),
            })
          end,
        },
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf, remap = false }
          vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
          vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
          vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
          vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
        end,
      })
    end
  },

 -- Bing 翻譯與命名風格覆蓋
  require("plugins.translator"),
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end
  },

  -- 自動括號
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end
  },

  -- Tree-sitter 語法解析
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      local languages = { "c", "cpp", "lua", "vim", "vimdoc" }
      local treesitter = require("nvim-treesitter")
      treesitter.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      local function start_treesitter(bufnr)
        local language = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
        if not language then return end

        local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr, language)
        if parser_ok and parser then
          vim.treesitter.start(bufnr, language)
          require("rainbow-delimiters").enable(bufnr)
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = languages,
        callback = function(args) start_treesitter(args.buf) end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(bufnr) then start_treesitter(bufnr) end
          end
        end,
      })

      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then start_treesitter(bufnr) end
      end

      local missing_cli = vim.fn.executable("tree-sitter") == 0
      local missing_parsers = {}
      for _, language in ipairs(languages) do
        local parser_ok, parser = pcall(vim.treesitter.get_parser, 0, language)
        if not parser_ok or not parser then
          table.insert(missing_parsers, language)
        end
      end

      if #missing_parsers > 0 then
        if missing_cli then
          vim.notify("缺少 Tree-sitter parser（" .. table.concat(missing_parsers, ", ") .. "）。", vim.log.levels.WARN)
        else
          treesitter.install(missing_parsers)
        end
      end
    end,
  },

  -- 彩虹括號
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      local rainbow = require("rainbow-delimiters")
      local group = vim.api.nvim_create_augroup("UserRainbowDelimiters", { clear = true })

      local function attach_if_parser_exists(bufnr)
        local language = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
        if not language then return end

        local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr, language)
        if parser_ok and parser then
          rainbow.enable(bufnr)
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "c", "cpp", "lua", "vim", "vimdoc" },
        callback = function(args) attach_if_parser_exists(args.buf) end,
      })

      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) then attach_if_parser_exists(bufnr) end
      end
    end,
  },

  -- 按鍵選單提示 (Which-key)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>f", group = "搜尋/格式化" },
        { "<leader>w", group = "視窗管理" },
        { "<leader>h", group = "Git 修改預覽" },
        { "<leader>t", group = "翻譯/終端機" },
      })
    end,
  },

  -- mini.animate 動態視覺
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      require("mini.animate").setup({
        cursor = { enable = true },
        scroll = { enable = true },
      })
    end,
  },

  -- 底部狀態列
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          component_separators = { left = '·', right = '·' },
          section_separators = { left = '', right = ''},
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = {
            {
              function()
                local msg = 'No LSP'
                local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
                local clients = vim.lsp.get_clients()
                if next(clients) == nil then return msg end
                for _, client in ipairs(clients) do
                  local filetypes = client.config.filetypes
                  if filetypes and vim.list_contains(filetypes, buf_ft) then
                    return '⚙ ' .. client.name
                  end
                end
                return msg
              end,
              color = { fg = '#b358b6', gui = 'bold' },
            },
            {
              function()
                return " " .. os.date("%m/%d %H:%M")
              end,
            },
            'encoding',
            'filetype',
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
      })
    end,
  },

  -- 頂部分頁列 (bufferline)
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require("bufferline").setup({
        highlights = {
          fill = { fg = "#565f89", bg = "NONE" },
          background = { fg = "#a9b1d6", bg = "NONE" },
          buffer = { bg = "NONE" },
          buffer_visible = { fg = "#a9b1d6", bg = "NONE" },
          buffer_selected = { fg = "#ffffff", bg = "#8b0e8f", bold = true },
          separator = { bg = "NONE" },
          separator_visible = { bg = "NONE" },
          separator_selected = { fg = "#8b0e8f", bg = "#8b0e8f" },
          numbers = { fg = "#565f89", bg = "NONE" },
          numbers_visible = { fg = "#8b0e8f", bg = "NONE" },
          numbers_selected = { fg = "#ffffff", bg = "#8b0e8f", bold = true },
          diagnostic_selected = { fg = "#ffffff", bg = "#8b0e8f", bold = true },
          error_selected = { fg = "#ffffff", bg = "#8b0e8f", bold = true },
          warning_selected = { fg = "#ffffff", bg = "#8b0e8f", bold = true },
          info_selected = { fg = "#ffffff", bg = "#8b0e8f", bold = true },
          hint_selected = { fg = "#ffffff", bg = "#8b0e8f", bold = true },
          modified_selected = { fg = "#ffffff", bg = "#8b0e8f", bold = true },
          duplicate_selected = { fg = "#ffffff", bg = "#8b0e8f", bold = true },
          indicator_selected = { fg = "#ffffff", bg = "#8b0e8f", bold = true },
          close_button = { fg = "#565f89", bg = "NONE" },
          close_button_visible = { fg = "#a9b1d6", bg = "NONE" },
          close_button_selected = { fg = "#ffffff", bg = "#8b0e8f", bold = true },
        },
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              text_align = "left",
              separator = true,
            }
          },
        }
      })
      vim.keymap.set("n", "<A-h>", "<cmd>BufferLineCyclePrev<CR>", { silent = true })
      vim.keymap.set("n", "<A-l>", "<cmd>BufferLineCycleNext<CR>", { silent = true })
      vim.keymap.set("n", "gt", "<cmd>BufferLineCycleNext<CR>", { silent = true, desc = "切換至下一個緩衝區" })
      vim.keymap.set("n", "gT", "<cmd>BufferLineCyclePrev<CR>", { silent = true, desc = "切換至上一個緩衝區" })
    end,
  },

  -- 右側捲動條
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require("scrollbar").setup()
    end,
  },

  -- 縮排對齊線
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },


}

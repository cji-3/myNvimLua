# Neovim 設定指南

這份文件整理本設定提供的快捷鍵、插件操作與主要功能。新增或修改快捷鍵、插件功能時，請同步更新本文件。

## 基本說明

- `<leader>` 預設為空白鍵。例如 `<leader>ff` 就是依序按 `Space`、`f`、`f`。
- `<C-x>` 表示 `Ctrl+x`；`<A-x>` 表示 `Alt+x`。
- 除非另有註明，快捷鍵在 Normal 模式使用。
- `<leader>wc` 關閉目前檔案 buffer，不是關閉視窗；保留未儲存檔案，需先儲存或自行放棄變更。

## 快捷鍵一覽

### 檔案與搜尋

| 快捷鍵 | 模式 | 功能 |
| --- | --- | --- |
| `<C-n>` | Normal | 切換 NvimTree 檔案樹 |
| `<leader>e` | Normal | 切換 NvimTree 檔案樹 |
| `<leader>ff` | Normal | Telescope 搜尋專案檔案 |
| `<leader>fg` | Normal | Telescope 搜尋程式碼內容（Live Grep） |
| `<leader>fb` | Normal | Telescope 搜尋已開啟的 buffer |
| `<leader>fh` | Normal | 搜尋 Neovim 說明文件 |
| `<leader>nh` | Normal | 清除搜尋結果反白（`:nohlsearch`） |

### 視窗與 buffer

| 快捷鍵 | 功能 |
| --- | --- |
| `<leader>wh` / `<leader>wj` / `<leader>wk` / `<leader>wl` | 移至左／下／上／右側視窗 |
| `<leader>wn` | 恢復最近開啟的檔案編輯區；若目前只有檔案樹則保留檔案樹並開回該檔案 |
| `<leader>ws` | 水平分割視窗 |
| `<leader>wv` | 垂直分割視窗 |
| `<leader>wc` | 關閉目前檔案 buffer；切換至其他一般檔案，若沒有其他檔案則留下空白編輯區 |
| `<leader>wC` | 強制關閉目前檔案 buffer，直接丟棄未儲存變更 |
| `<leader>wo` | 關閉其他視窗 |
| `<leader>w=` | 平均調整所有視窗大小 |
| `<leader>Q` | 退出所有視窗 |
| `gt` / `gT` | 切換至下一個／上一個 buffer |
| `<A-l>` / `<A-h>` | 切換至下一個／上一個 buffer |

`<leader>wc` 不會強制關閉有未儲存修改的檔案；`<leader>wC` 會直接丟棄未儲存變更，請小心使用。直接輸入 `:bd`、`:q` 則維持 Neovim 原生行為。

### Git

| 快捷鍵 | 功能 |
| --- | --- |
| `<leader>gs` | 開啟 Fugitive Git 狀態面板 |
| `<leader>gd` | 開啟 Git 差異檢視 |
| `<leader>ga` | 儲存並暫存目前檔案（Fugitive `:Gwrite`） |
| `<leader>gc` | 提交 Git 變更並輸入 commit message |
| `<leader>gf` | 執行 Git fetch，取得遠端更新但不合併 |
| `<leader>gl` | 執行 Git pull，拉取並整合遠端更新 |
| `<leader>gp` | 執行 Git push |
| `[h` / `]h` | 跳至上一個／下一個 Git 修改區塊 |
| `<leader>hp` | 預覽目前 Git 修改區塊 |

Fugitive 狀態面板常用操作（先以 `<leader>gs` 開啟）：

| 按鍵 | 功能 |
| --- | --- |
| `s` | 暫存游標所在檔案或區塊 |
| `u` | 取消游標所在檔案或區塊的暫存 |
| `-` | 切換暫存狀態 |
| `U` | 取消全部暫存 |
| `X` | 捨棄游標所在的修改；此操作會丟棄變更，請小心 |
| `=` | 切換游標所在檔案的行內差異 |
| `<Enter>` | 開啟游標所在檔案或 Git 物件 |
| `?` | 查看 Fugitive 狀態面板的完整按鍵說明 |

### 編輯、格式化與 LSP

| 快捷鍵 | 模式 | 功能 |
| --- | --- | --- |
| `jk` | Insert | 返回 Normal 模式（等同 `Esc`） |
| `<leader>cf` | Normal | 使用 clangd 格式化目前 buffer |
| `<leader>z` | Normal，C/C++ | 游標在成對括號內時，清理目前行距離最近的多餘 `)`／`}` |
| `<leader>xx` | Normal | 開啟／關閉所有檔案的錯誤與警告清單 |
| `<leader>xX` | Normal | 開啟／關閉目前檔案的錯誤與警告清單 |
| `gd` | Normal，clangd 附加時 | 跳至定義 |
| `K` | Normal，clangd 附加時 | 顯示符號說明 |
| `[d` / `]d` | Normal，clangd 附加時 | 跳至上一個／下一個診斷 |
| `s` | Normal、Visual、Operator-pending | Flash 快速跳轉 |
| `S` | Normal、Visual、Operator-pending | Flash Tree-sitter 跳轉／選取 |

多游標編輯（vim-visual-multi）：

| 快捷鍵 | 功能 |
| --- | --- |
| `<leader>m` | 選取游標下單字並加入下一個相同位置；重複按可繼續加入 |
| `<C-j>` / `<C-k>` | 在下方／上方新增游標（Normal 模式；Insert 模式仍用於補全選項） |
| `n` / `N` | 選取下一個／上一個相同位置 |
| `<Tab>` | 切換游標模式與延伸選取模式 |
| `q` / `Q` | 跳過目前匹配／移除目前游標 |
| `Esc` | 結束多游標編輯 |

括號、引號包覆（mini.surround）：

| 快捷鍵 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>sa` | Normal | 後接移動／文字物件與符號，為文字加上包覆；例如 `<leader>sa` `iw` `)` 為單字加上括號 |
| `<leader>sa` | Visual | 為選取文字加上括號、引號等包覆 |
| `<leader>sd` | Normal | 後接符號，刪除游標附近的該層包覆 |
| `<leader>sr` | Normal | 後接舊符號與新符號，替換包覆 |

快速文字物件（mini.ai）可在 Visual 或 Operator-pending 模式使用：

| 文字物件 | 功能 |
| --- | --- |
| `a)` / `i)`、`a]` / `i]`、`a}` / `i}` | 選取含括號／括號內的內容 |
| `aq` / `iq` | 選取含引號／引號內的內容 |
| `aa` / `ia` | 選取含參數分隔符／參數本身 |
| `af` / `if` | 選取函式呼叫／呼叫內容 |
| `aF` / `iF` | 以 Tree-sitter 選取函式定義／函式本體（C、C++、Python） |

文字或選取區塊移動（mini.move）：Normal 模式按 `<A-j>`／`<A-k>` 移動目前行；Visual 模式選取區塊後按同組按鍵移動區塊。

括號自動配對（nvim-autopairs）：Insert 模式輸入 `(`、`[`、`{` 或引號會自動補上配對符號；在中間按 `<BS>` 刪除一對，按 `<Enter>` 在括號中間換行。HTML/XML 輸入開始標籤後按 `>` 會自動補結束標籤，編輯標籤名稱時也會同步更名。

在 C/C++ 中按 `<leader>z`（`Space`、`z`），只有游標位於整個檔案中確定成對的 `()`／`{}` 內才會執行。若這組括號後方同一行有多出的同類右括號，會刪除距離游標最近的閉合符號，讓後方括號接替配對；否則只刪除最近的不成對右括號。每次只刪一個，還有多餘括號時可再按一次。掃描會考慮跨行配對，並忽略註解與字串；若游標不在成對括號內或沒有可處理的右括號，內容不會變更。不需要等待 clangd 診斷。

在函式呼叫中輸入 `(` 或 `,` 時，clangd 會自動開啟帶圓角框的簽名提示，並標示目前參數。按 `K` 會以 Markdown 浮窗顯示 clangd hover 文件；若函式有 Doxygen 註解，設定會將 brief、參數、回傳值等標籤轉成易讀格式。

自動補全（Insert 模式）：

| 快捷鍵 | 功能 |
| --- | --- |
| `<C-j>` / `<Tab>` | 選擇下一個補全項目 |
| `<C-k>` / `<S-Tab>` | 選擇上一個補全項目 |
| `<C-b>` | 手動觸發補全（`<C-Space>` 保留給輸入法） |
| `<Enter>` | 確認補全項目 |

在 C/C++ 註解中輸入 `\` 可補全常用 Doxygen 標籤，例如 `\param`、`\return`。

Comment.nvim 使用預設映射：`gcc` 切換目前行註解；`gc` 加上移動命令可註解選取範圍；`gbc`／`gb` 使用區塊註解。

### Bing 翻譯

一般翻譯可在 Normal 模式將游標放在單字上，或先選取文字；命名風格替換需先在 Visual 模式選取文字。

| 快捷鍵 | 模式 | 功能 |
| --- | --- | --- |
| `<leader>te` | Normal／Visual | Bing 中翻英，顯示游標下方彈窗 |
| `<leader>tz` | Normal／Visual | Bing 英翻中，顯示游標下方彈窗 |
| `<leader>tse` | Normal／Visual | Bing 中翻英，以通知顯示結果 |
| `<leader>tsz` | Normal／Visual | Bing 英翻中，以通知顯示結果 |
| `<leader>tte` | Visual | 中翻英並轉為小分詞底線分割 |
| `<leader>tTE` | Visual | 中翻英並轉為常量 |
| `<leader>ttE` | Visual | 中翻英並轉為小駝峰 |
| `<leader>tTe` | Visual | 中翻英並轉為大駝峰 |
| `<leader>tE` | Visual | 中翻英並以小寫空格分隔 |
| `<leader>ttz` | Visual | 英翻中並以原始翻譯文字替換 |

彈窗使用自動尺寸、圓角邊框與方向標題，並盡量顯示在游標下方。按 `q`、`Esc` 或 `Enter` 關閉彈窗。

### 終端機

| 快捷鍵 | 功能 |
| --- | --- |
| `<leader>/` | 在底部開啟內建終端機並進入輸入模式 |
| `Ctrl+\`，接著 `Ctrl+n` | 從終端機模式返回 Normal 模式 |
| `<C-q>` | 關閉終端機並結束 shell 程序 |
| `i` | 從 Normal 模式返回終端機輸入模式 |

在終端機輸入 `:q` 會把文字送給 shell，因為此時不是 Neovim 命令模式。要關閉終端機可直接按 `<C-q>`；或先按 `Ctrl+\`、`Ctrl+n` 離開終端機模式，再執行 `:q` 關閉視窗（shell 程序會繼續執行）。

### 重新載入設定

| 快捷鍵 | 功能 |
| --- | --- |
| `<leader>r` | 重新載入 `init.lua` 與 `config.editor`；已載入插件的設定變更可能需要重開 Neovim |
| `:NvimCheckEnv` | 手動檢查 Git、GCC、LLVM clangd 與 Tree-sitter parser 等外部依賴 |

Neovim 啟動後會自動檢查外部依賴；若有缺少，會列出名稱和用途。clangd 可由 Mason 安裝：`:MasonInstall clangd`。

## 主要功能

- **C/C++ 開發**：Mason 管理 clangd；支援補全、跳轉定義、說明、診斷與 clangd 格式化。游標所在函式／條件區塊的 scope 提示使用亮色粗體、不加底線。格式化使用 4 格縮排設定。
- **語法與括號**：Tree-sitter 支援 C、C++（`.ino` 以 C++ 開啟）、Lua、Vim、Vim help、Markdown、Python、JSON、HTML 與 XML；`.bat` 使用 Neovim 內建語法高亮；彩虹括號使用三色循環；C/C++ 註解中的 Doxygen 標籤（如 `\param`、`@return`）以金色粗體顯示並支援補全。
- **Git**：vim-fugitive 提供互動狀態／差異檢視與 Git 命令；Gitsigns 在行側標示修改區塊。
- **檔案導覽**：NvimTree 檔案樹與 Telescope 檔案、文字、buffer 搜尋。
- **編輯輔助**：nvim-cmp 補全、nvim-autopairs 自動括號配對、nvim-ts-autotag HTML/XML 標籤配對、mini.surround 包覆操作、mini.ai 文字物件、mini.move 區塊移動、Trouble 診斷面板、Comment.nvim 註解、Flash 快速跳轉、vim-visual-multi 多游標編輯。
- **介面**：Tokyo Night 主題、透明背景、絕對／相對行號、縮排導引線、Bufferline、Lualine 狀態列、Scrollbar、診斷提示；游標與捲動畫面不使用動態動畫。
- **翻譯**：Bing 英中翻譯，提供彈窗、通知與命名風格替換。

## 使用者設定

- 設定目錄中的 `lua/config/editor.lua` 管理基本選項與快捷鍵。
- `lua/config/plugins.lua` 管理插件規格與插件設定。
- `lua/plugins/` 存放個別插件設定，例如翻譯和 Fugitive 中文標題。
- 調整或新增快捷鍵、插件功能時，請同步更新本指南。

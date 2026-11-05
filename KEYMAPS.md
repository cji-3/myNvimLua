# Neovim 快捷鍵與功能指南

這份指南依照常見操作情境整理快捷鍵，也說明主要插件功能。要找按鍵時，可先看「快速查找」；新增或修改快捷鍵、插件功能時，請同步更新本文件。

另有互動版 [KEYMAPS.html](./KEYMAPS.html)，提供全文搜尋、快捷鍵複製與列印樣式；不取代本 Markdown 指南。

## 目錄

- [快速查找](#快速查找)
- [閱讀方式](#閱讀方式)
- [檔案、搜尋與視窗](#檔案搜尋與視窗)
- [Git 與分支](#git-與分支)
- [程式編輯、LSP 與診斷](#程式編輯lsp-與診斷)
- [文字操作與補全](#文字操作與補全)
- [翻譯](#翻譯)
- [終端機](#終端機)
- [設定與環境檢查](#設定與環境檢查)
- [主要功能](#主要功能)
- [設定檔位置](#設定檔位置)

## 快速查找

| 想要…… | 使用 |
| --- | --- |
| 開啟檔案或搜尋程式碼 | `<Space>ff` / `<Space>fg` |
| 切換檔案樹 | `<Space>e` 或 `<C-n>` |
| 在瀏覽器查看互動版指南 | `<Space>H` |
| 在瀏覽器查看 Markdown 指南 | `<Space>h` |
| 開啟 Git 狀態或切換分支 | `<Space>gs` / `<Space>gB` |
| 重新命名 LSP 符號 | `<Space>lr` |
| 查看錯誤與警告清單 | `<Space>xx` |
| 開啟下方終端機 | `<Space>c` |
| 暫時離開終端機但保留程序 | 終端機中按 `<C-g>` |
| 關閉目前檔案或終端機 | `<Space>wc` |

## 閱讀方式

- `<Space>` 代表空白鍵，也就是 `<leader>`。例如 `<leader>ff` 就是依序按 `Space`、`f`、`f`。
- `<C-x>` 表示 `Ctrl+x`；`<A-x>` 表示 `Alt+x`。
- 除非另有註明，快捷鍵在 Normal 模式使用。
- `LSP 附加時` 表示該檔案已有語言伺服器提供功能；目前 C/C++ 主要使用 clangd。
- 按下 `<Space>` 後稍候，可透過 which-key 查看可用快捷鍵提示。

## 檔案、搜尋與視窗

### 開啟檔案與搜尋

| 快捷鍵 | 模式 | 功能 |
| --- | --- | --- |
| `<C-n>` / `<Space>e` | Normal | 開啟或關閉 NvimTree 檔案樹 |
| `<Space>ff` | Normal | Telescope 搜尋檔案 |
| `<Space>fg` | Normal | Telescope 搜尋程式碼內容（Live Grep） |
| `<Space>fb` | Normal | 搜尋已開啟的 buffer |
| `<Space>fh` | Normal | 搜尋 Neovim 說明文件 |
| `<Space>H` | Normal | 在瀏覽器中開啟互動版 `KEYMAPS.html` |
| `<Space>h` | Normal | 在瀏覽器中開啟 `KEYMAPS.md` |
| `<Space>nh` | Normal | 清除搜尋結果反白 |

### 視窗與 buffer

| 快捷鍵 | 功能 |
| --- | --- |
| `<Space>wh` / `<Space>wj` / `<Space>wk` / `<Space>wl` | 移至左／下／上／右側視窗 |
| `<Space>ws` / `<Space>wv` | 水平／垂直分割視窗 |
| `<Space>wn` | 恢復最近開啟的檔案編輯區；若目前只有檔案樹，保留檔案樹並開回檔案 |
| `<Space>wc` | 安全關閉目前檔案 buffer；若目前是終端機，則關閉終端機 |
| `<Space>wC` | 強制關閉目前檔案 buffer，丟棄未儲存變更 |
| `<Space>wo` | 關閉其他視窗 |
| `<Space>w=` | 平均調整所有視窗大小 |
| `<Space>Q` | 退出所有視窗 |
| `gt` / `gT` | 切換至下一個／上一個 buffer |
| `<A-l>` / `<A-h>` | 切換至下一個／上一個 buffer |

`<Space>wc` 不會強制關閉有未儲存修改的檔案；請先儲存或自行放棄變更。用它關閉終端機時會結束 shell，並盡量保留編輯區與檔案樹。`<Space>wC` 會直接丟棄未儲存變更，請小心使用。直接輸入 `:bd`、`:q` 則維持 Neovim 原生行為。

## Git 與分支

### Git 操作

| 快捷鍵 | 功能 |
| --- | --- |
| `<Space>gs` | 開啟 Fugitive Git 狀態面板 |
| `<Space>gd` | 開啟 Git 差異檢視 |
| `<Space>ga` | 儲存並暫存目前檔案（`:Gwrite`） |
| `<Space>gc` | 提交 Git 變更並輸入 commit message |
| `<Space>gf` | 執行 Git fetch，取得遠端更新但不合併 |
| `<Space>gl` | 執行 Git pull，拉取並整合遠端更新 |
| `<Space>gp` | 執行 Git push |
| `<Space>gb` | 列出本地 Git 分支 |
| `<Space>gB` | 輸入分支名稱並切換分支 |
| `<Space>gN` | 輸入名稱以建立並切換至新分支 |
| `<Space>gD` | 輸入本地分支名稱，確認後安全刪除已合併分支 |
| `[h` / `]h` | 跳至上一個／下一個 Git 修改區塊 |
| `<Space>hp` | 預覽目前 Git 修改區塊 |

### Fugitive 狀態面板

先按 `<Space>gs` 開啟狀態面板，再使用以下按鍵：

| 按鍵 | 功能 |
| --- | --- |
| `s` | 暫存游標所在檔案或區塊 |
| `u` | 取消游標所在檔案或區塊的暫存 |
| `-` | 切換暫存狀態 |
| `U` | 取消全部暫存 |
| `X` | 捨棄游標所在的修改（會丟棄變更） |
| `=` | 切換游標所在檔案的行內差異 |
| `<Enter>` | 開啟游標所在檔案或 Git 物件 |
| `?` | 查看 Fugitive 狀態面板的完整按鍵說明 |

## 程式編輯、LSP 與診斷

### 常用程式編輯與 LSP

| 快捷鍵 | 模式 | 功能 |
| --- | --- | --- |
| `jk` | Insert | 返回 Normal 模式（等同 `Esc`） |
| `<Space>cf` | Normal | 使用 clangd 格式化目前 buffer |
| `<Space>z` | Normal，C/C++ | 清理游標附近多餘的 `)`／`}` |
| `gd` | Normal，LSP 附加時 | 跳至定義 |
| `K` | Normal，LSP 附加時 | 顯示符號說明 |
| `<Space>lr` | Normal，LSP 附加時 | 重新命名游標所在的符號 |
| `<Space>la` | Normal，LSP 附加時 | 顯示游標所在符號可用的程式碼動作 |
| `<Space>ld` | Normal，LSP 附加時 | 跳至宣告 |
| `<Space>li` | Normal，LSP 附加時 | 跳至實作 |
| `<Space>lR` | Normal，LSP 附加時 | 尋找游標所在符號的引用 |
| `<Space>lt` | Normal，LSP 附加時 | 跳至型別定義 |

在函式呼叫中輸入 `(` 或 `,` 時，clangd 會自動開啟簽名提示並標示目前參數。按 `K` 會以 Markdown 浮窗顯示 hover 文件；若函式有 Doxygen 註解，內容會整理成易讀格式。

### 診斷與錯誤清單

| 快捷鍵 | 模式 | 功能 |
| --- | --- | --- |
| `[d` | Normal，LSP 附加時 | 跳至下一個診斷 |
| `]d` | Normal，LSP 附加時 | 跳至上一個診斷 |
| `<Space>xx` | Normal | 開啟／關閉所有檔案的診斷清單 |
| `<Space>xX` | Normal | 開啟／關閉目前檔案的診斷清單 |

收到錯誤或警告診斷後，設定會等待約一秒，再嘗試使用 Bing 翻譯並把繁體中文譯文附加在對應行尾，不必移動游標。譯文沿用錯誤／警告色系並調亮顯示。診斷訊息會傳送至 Bing；翻譯失敗時不顯示通知，並暫停自動重試一分鐘，原始診斷仍正常顯示。

## 文字操作與補全

### 快速跳轉與多游標

| 快捷鍵 | 模式 | 功能 |
| --- | --- | --- |
| `s` | Normal、Visual、Operator-pending | Flash 快速跳轉 |
| `S` | Normal、Visual、Operator-pending | Flash Tree-sitter 跳轉／選取 |
| `<Space>m` | Normal | 選取游標下單字並加入下一個相同位置；重複按可繼續加入 |
| `<C-j>` / `<C-k>` | Normal | 在下方／上方新增多游標 |
| `n` / `N` | 多游標編輯 | 選取下一個／上一個相同位置 |
| `<Tab>` | 多游標編輯 | 切換游標模式與延伸選取模式 |
| `q` / `Q` | 多游標編輯 | 跳過目前匹配／移除目前游標 |
| `Esc` | 多游標編輯 | 結束多游標編輯 |

`<C-j>`、`<C-k>` 與 `<Tab>` 在 Insert 模式仍用於補全選項。

### 包覆、文字物件與移動

括號、引號包覆（mini.surround）：

| 快捷鍵 | 模式 | 功能 |
| --- | --- | --- |
| `<Space>sa` | Normal | 後接移動／文字物件與符號，為文字加上包覆；例如 `<Space>sa`、`iw`、`)` 為單字加括號 |
| `<Space>sa` | Visual | 為選取文字加上括號、引號等包覆 |
| `<Space>sd` | Normal | 後接符號，刪除游標附近的該層包覆 |
| `<Space>sr` | Normal | 後接舊符號與新符號，替換包覆 |

快速文字物件（mini.ai）可在 Visual 或 Operator-pending 模式使用：

| 文字物件 | 功能 |
| --- | --- |
| `a)` / `i)`、`a]` / `i]`、`a}` / `i}` | 選取含括號／括號內的內容 |
| `aq` / `iq` | 選取含引號／引號內的內容 |
| `aa` / `ia` | 選取含參數分隔符／參數本身 |
| `af` / `if` | 選取函式呼叫／呼叫內容 |
| `aF` / `iF` | 以 Tree-sitter 選取函式定義／函式本體（C、C++、Python） |

文字或選取區塊移動（mini.move）：Normal 模式按 `<A-j>`／`<A-k>` 移動目前行；Visual 模式選取區塊後按同組按鍵移動區塊。

### 補全、括號與註解

自動補全在 Insert 模式使用：

| 快捷鍵 | 功能 |
| --- | --- |
| `<C-j>` / `<Tab>` | 選擇下一個補全項目 |
| `<C-k>` / `<S-Tab>` | 選擇上一個補全項目 |
| `<C-b>` | 手動觸發補全（`<C-Space>` 保留給輸入法） |
| `<Enter>` | 確認補全項目 |

補全候選會忽略大小寫與標點符號比較名稱，較短的候選優先顯示。C/C++ 註解中輸入 `\` 可補全常用 Doxygen 標籤，例如 `\param`、`\return`。

nvim-autopairs 會在 Insert 模式自動配對括號與引號：在配對中按 `<BS>` 可刪除一對，按 `<Enter>` 可在括號中間換行。HTML/XML 輸入開始標籤後按 `>` 會補上結束標籤；編輯標籤名稱時也會同步更名。

Comment.nvim 使用預設映射：`gcc` 切換目前行註解；`gc` 加上移動命令可註解選取範圍；`gbc`／`gb` 使用區塊註解。

在 C/C++ 中按 `<Space>z` 可清理游標附近多餘的 `)`／`}`。游標必須位於整個檔案中確定成對的 `()`／`{}` 內；若該組括號後方同一行有多出的同類右括號，會刪除距離游標最近的閉合符號，否則刪除最近的不成對右括號。每次只刪一個；掃描會考慮跨行配對並忽略註解與字串，不需要等待 clangd 診斷。

## 翻譯

一般翻譯可在 Normal 模式將游標放在單字上，或先選取文字；命名風格轉換需先在 Visual 模式選取文字。

| 快捷鍵 | 模式 | 功能 |
| --- | --- | --- |
| `<Space>te` | Normal／Visual | 中翻英，結果顯示於游標附近彈窗 |
| `<Space>tz` | Normal／Visual | 英翻中，結果顯示於游標附近彈窗 |
| `<Space>tse` | Normal／Visual | 中翻英，以通知顯示結果 |
| `<Space>tsz` | Normal／Visual | 英翻中，以通知顯示結果 |
| `<Space>tte` | Visual | 中翻英並轉為小寫底線命名（snake_case） |
| `<Space>tTE` | Visual | 中翻英並轉為常量命名（UPPER_SNAKE_CASE） |
| `<Space>ttE` | Visual | 中翻英並轉為小駝峰（camelCase） |
| `<Space>tTe` | Visual | 中翻英並轉為大駝峰（PascalCase） |
| `<Space>tE` | Visual | 中翻英並轉為小寫空格分隔 |
| `<Space>ttz` | Visual | 英翻中並以原始翻譯文字替換 |

翻譯彈窗會自動調整尺寸並使用圓角邊框，按 `q`、`Esc` 或 `Enter` 關閉。翻譯使用 Bing 網路服務。

## 終端機

| 快捷鍵 | 模式 | 功能 |
| --- | --- | --- |
| `<Space>/` | Normal | 在新分頁開啟內建終端機並進入輸入模式 |
| `<Space>c` | Normal | 在目前視窗下方開啟內建終端機並進入輸入模式 |
| `<C-g>` | Terminal | 返回上一個 buffer，保留終端機程序 |
| `<C-q>` | Terminal | 關閉終端機並結束 shell 程序 |
| `Ctrl+\`，接著 `Ctrl+n` | Terminal | 返回 Normal 模式 |
| `i` | Normal，終端機 buffer | 返回終端機輸入模式 |

終端機文字使用橘色顯示。在終端機輸入 `:q` 會把文字送給 shell，而不是執行 Neovim 命令。要暫時離開並保留 shell，按 `<C-g>`；要結束 shell 並關閉終端機，按 `<C-q>`。也可按 `Ctrl+\`、`Ctrl+n` 離開終端機模式，再執行 `:q` 關閉視窗；此方式不會結束 shell 程序。

## 設定與環境檢查

| 命令／快捷鍵 | 功能 |
| --- | --- |
| `<Space>r` | 重新載入 `init.lua` 與 `config.editor` |
| `:NvimCheckEnv` | 手動檢查 Git、GCC、LLVM clangd 與 Tree-sitter parser 等外部依賴 |
| `:MasonInstall clangd` | 透過 Mason 安裝 clangd |

Neovim 啟動後會自動檢查外部依賴；若有缺少，會列出名稱和用途。重新載入設定後，已載入插件的設定變更可能仍需重開 Neovim。

## 主要功能

- **C/C++ 開發**：Mason 管理 clangd，提供補全、符號導覽、診斷與格式化；函式及條件區塊 scope 提示使用亮色粗體、不加底線；格式化使用 4 格縮排設定。
- **語法與括號**：Tree-sitter 支援 C、C++（`.ino` 以 C++ 開啟）、Lua、Vim、Vim help、Markdown、Python、JSON、HTML 與 XML；`.bat` 使用 Neovim 內建語法高亮；彩虹括號使用三色循環；Doxygen 標籤以金色粗體顯示並支援補全。
- **Git**：vim-fugitive 提供互動式狀態／差異檢視與 Git 命令；Gitsigns 在行側標示修改區塊。
- **檔案導覽**：NvimTree 檔案樹與 Telescope 檔案、文字及 buffer 搜尋。
- **編輯輔助**：nvim-cmp 補全、nvim-autopairs 括號配對、nvim-ts-autotag HTML/XML 標籤配對、mini.surround 包覆操作、mini.ai 文字物件、mini.move 區塊移動、Trouble 診斷面板、Comment.nvim 註解、Flash 快速跳轉及 vim-visual-multi 多游標編輯。
- **介面**：Tokyo Night 主題、透明背景、絕對／相對行號、縮排導引線、Bufferline、Lualine 狀態列、Scrollbar 與診斷提示；游標及捲動畫面不使用動態動畫。
- **翻譯**：Bing 英中翻譯、命名風格替換，以及診斷訊息自動翻譯。

## 設定檔位置

- `lua/config/editor.lua`：基本選項、一般快捷鍵、視窗與終端機行為。
- `lua/config/plugins.lua`：插件規格、插件設定與 LSP 快捷鍵。
- `lua/plugins/`：個別插件設定，例如翻譯與 Fugitive 中文標題。

調整或新增快捷鍵、插件功能時，請同步更新本指南。

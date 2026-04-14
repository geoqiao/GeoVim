-- ============================================
-- 快捷键映射 (Keymaps) —— 纯粹 Vim 原生风格
-- ============================================
-- 设计原则：
-- 1. 完全尊重 Vim 原生按键逻辑，不覆盖任何经典的 hjkl/0$ggG/uCtrl+r 等
-- 2. 只保留极少数现代环境的通用约定：Ctrl+S 保存、jk 退出 insert、; 进命令模式
-- 3. 所有高级功能统一放在 <leader>（空格）二级菜单下，配合 which-key 提示
-- 4. 复制、移动、选中、跳转全部使用 Vim 原生方式（y/d/c/f/t/0$^ggG 等）

local map = vim.keymap.set

-- ============================================
-- 一、现代环境的少量妥协（保留）
-- ============================================

-- 按 ";" 快速进入命令模式（不用按 Shift+:）
map("n", ";", ":", { desc = "进入命令模式", nowait = true })

-- 按 "jk" 快速退出 Insert 模式（手不用离开主键区）
map("i", "jk", "<ESC>", { desc = "退出插入模式" })

-- 终端模式下按 jk 或 Esc 快速回到 Normal 模式（方便切窗口）
map("t", "jk", "<C-\\><C-n>", { desc = "退出终端模式" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "退出终端模式" })

-- Ctrl+S 保存文件（几乎所有编辑器都一样的习惯）
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>", { desc = "保存文件" })

-- ============================================
-- 二、系统剪贴板（仅作为 leader 备用，不覆盖 y/p）
-- ============================================
-- Vim 原生 yy/p 是最快的编辑方式。这里只是提供一个备用入口，方便偶尔和系统交互。

map({ "n", "v" }, "<leader>y", '"+y', { desc = "复制到系统剪贴板" })
map("n", "<leader>Y", '"+Y', { desc = "复制整行到系统剪贴板" })

-- ============================================
-- 三、Telescope 搜索（基于 leader 触发）
-- ============================================
-- 记忆口诀：leader + f(finding) 开头

map("n", "<leader>ff", "<cmd> Telescope find_files <cr>",
  { desc = "查找文件" })
map("n", "<leader>fw", "<cmd> Telescope live_grep <cr>",
  { desc = "全局文本搜索 (live grep)" })
map("n", "<leader>fb", "<cmd> Telescope buffers <cr>",
  { desc = "查找已打开的 Buffer" })
map("n", "<leader>fo", "<cmd> Telescope oldfiles <cr>",
  { desc = "最近打开的文件" })
map("n", "<leader>fh", "<cmd> Telescope help_tags <cr>",
  { desc = "搜索帮助文档" })
map("n", "<leader>fk", "<cmd> Telescope keymaps <cr>",
  { desc = "搜索快捷键" })
map("n", "<leader>fc", "<cmd> Telescope grep_string <cr>",
  { desc = "搜索光标下的单词" })

-- ============================================
-- 四、文件树
-- ============================================

map("n", "<leader>ee", "<cmd> NvimTreeToggle <cr>",
  { desc = "显示/隐藏文件树" })
map("n", "<leader>eo", "<cmd> NvimTreeFocus <cr>",
  { desc = "聚焦文件树" })

-- ============================================
-- 五、Buffer（标签页）管理
-- ============================================
-- 使用 H / L 来回切换 Buffer。
-- 注意：这里覆盖了 Vim 原生的 H（跳到屏幕顶部）和 L（跳到屏幕底部）。
-- 这两个原生命令使用频率极低，且可用 zt / zb 替代。
-- 之所以不用 <Tab>，是因为 <Tab> 在 Vim 底层与 Ctrl-i 完全等价，覆盖它会
-- 破坏跳转列表（Ctrl-o / Ctrl-i 前进后退），这是 Vim 代码导航的核心闭环。
--
-- 重要：因为 bufferline.nvim 使用了自定义排序（sort_by），必须使用
-- BufferLineCyclePrev / BufferLineCycleNext 才能按视觉标签顺序切换。
-- 原生的 bprevious / bnext 会按 Vim 内部 buffer 编号跳转，导致切错标签。

map("n", "H", "<cmd> BufferLineCyclePrev <cr>", { desc = "上一个 Buffer" })
map("n", "L", "<cmd> BufferLineCycleNext <cr>", { desc = "下一个 Buffer" })
map("n", "<leader>x", "<cmd> bdelete <cr>", { desc = "关闭当前 Buffer" })
map("n", "<leader>X", "<cmd> %bdelete|edit #|normal `< <cr>",
  { desc = "关闭其他所有 Buffer" })

-- ============================================
-- 六、窗口分屏管理
-- ============================================

-- 在分屏窗口之间跳转
map("n", "<C-h>", "<C-w>h", { desc = "切换到左边窗口" })
map("n", "<C-j>", "<C-w>j", { desc = "切换到下方窗口" })
map("n", "<C-k>", "<C-w>k", { desc = "切换到上方窗口" })
map("n", "<C-l>", "<C-w>l", { desc = "切换到右边窗口" })

-- 快速创建分屏并打开终端
map("n", "<leader>sh", "<cmd> split | terminal <cr>", { desc = "打开水平分屏终端" })
map("n", "<leader>sv", "<cmd> vsplit | terminal <cr>", { desc = "打开垂直分屏终端" })

-- 调整分屏窗口大小
map("n", "<C-Up>", "<cmd> resize +2 <cr>", { desc = "增加窗口高度" })
map("n", "<C-Down>", "<cmd> resize -2 <cr>", { desc = "减少窗口高度" })
map("n", "<C-Left>", "<cmd> vertical resize -2 <cr>", { desc = "减少窗口宽度" })
map("n", "<C-Right>", "<cmd> vertical resize +2 <cr>", { desc = "增加窗口宽度" })

-- ============================================
-- 七、格式化
-- ============================================
-- 绑定为 <leader>cf（code format），放在 Code Action 分组下。
-- 如果绑在 <leader>f 上，会与 <leader>ff / <leader>fw 等 Telescope
-- 前缀冲突，导致每次按 <leader>f 都触发 400ms 的 timeout 等待。

map("n", "<leader>cf", function()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ async = true, lsp_fallback = true })
  else
    vim.lsp.buf.format({ async = true })
  end
end, { desc = "格式化当前文件" })

-- ============================================
-- 八、注释（Comment.nvim 提供的原生风格映射）
-- ============================================
-- gcc: normal 模式注释当前行
-- gc:  visual 模式注释选中内容
-- gb:  visual 模式块注释（由 Comment.nvim 默认提供）

local function toggle_comment()
  local ok, api = pcall(require, "Comment.api")
  if not ok then return end
  local mode = vim.fn.mode()
  if mode == "n" then
    api.toggle.linewise.current()
  elseif mode == "v" or mode == "V" or mode == "\22" then
    api.toggle.linewise(vim.fn.visualmode())
  end
end

map("n", "gcc", toggle_comment, { desc = "注释/取消注释当前行" })
map("v", "gc", toggle_comment, { desc = "注释/取消注释选中内容" })

-- ============================================
-- 九、Markdown
-- ============================================

map("n", "<leader>mp", "<cmd> MarkdownPreviewToggle <cr>",
  { desc = "浏览器 Markdown 预览" })

-- ============================================
-- 十、杂项小优化
-- ============================================

-- 按 Esc 清除搜索高亮
map("n", "<Esc>", "<cmd> noh <cr>", { desc = "清除搜索高亮" })

-- 翻页后光标保持在屏幕中间
map("n", "<C-d>", "<C-d>zz", { desc = "向下翻页并居中" })
map("n", "<C-u>", "<C-u>zz", { desc = "向上翻页并居中" })

-- Visual 模式下按 J/K 上下移动选中行（原生 Vim 风格）
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "下移选中行" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "上移选中行" })

-- Visual 模式下缩进后保持选中
map("v", "<", "<gv", { desc = "向左缩进并保持选中" })
map("v", ">", ">gv", { desc = "向右缩进并保持选中" })

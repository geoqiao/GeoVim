-- ============================================
-- 快捷键映射 (Keymaps) —— 纯粹 Vim 原生风格
-- ============================================
-- 设计原则：
-- 1. 完全尊重 Vim 原生按键逻辑，不覆盖任何经典的 hjkl/0$ggG/uCtrl+r/fFtT; 等
-- 2. 所有高级功能统一放在 <leader>（空格）二级菜单下，配合 which-key 提示
-- 3. 复制、移动、选中、跳转全部使用 Vim 原生方式（y/d/c/f/t/0$^ggG 等）

local map = vim.keymap.set

-- ============================================
-- 一、现代环境的少量妥协（保留）
-- ============================================

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

map("n", "<leader>ff", "<cmd> Telescope find_files <cr>", { desc = "查找文件" })
map("n", "<leader>fw", "<cmd> Telescope live_grep <cr>", { desc = "全局文本搜索 (live grep)" })
map("n", "<leader>fb", "<cmd> Telescope buffers <cr>", { desc = "查找已打开的 Buffer" })
map("n", "<leader>fo", "<cmd> Telescope oldfiles <cr>", { desc = "最近打开的文件" })
map("n", "<leader>fh", "<cmd> Telescope help_tags <cr>", { desc = "搜索帮助文档" })
map("n", "<leader>fk", "<cmd> Telescope keymaps <cr>", { desc = "搜索快捷键" })
map("n", "<leader>fc", "<cmd> Telescope grep_string <cr>", { desc = "搜索光标下的单词" })
map("n", "<leader>fi", "<cmd> Telescope current_buffer_fuzzy_find <cr>", { desc = "当前 Buffer 模糊查找" })

-- ============================================
-- 四、文件树
-- ============================================

map("n", "<leader>ee", "<cmd> NvimTreeToggle <cr>", { desc = "显示/隐藏文件树" })
map("n", "<leader>eo", "<cmd> NvimTreeFocus <cr>", { desc = "聚焦文件树" })

-- ============================================
-- 五、Buffer 管理
-- ============================================
-- 使用 <leader>b 分组，恢复 H / L 的原生屏幕导航功能。

map("n", "<leader>bn", "<cmd> bnext <cr>", { desc = "下一个 Buffer" })
map("n", "<leader>bp", "<cmd> bprevious <cr>", { desc = "上一个 Buffer" })
map("n", "<leader>bd", "<cmd> bdelete <cr>", { desc = "关闭当前 Buffer" })
map("n", "<leader>bD", "<cmd> %bdelete|edit #|normal `< <cr>", { desc = "关闭其他所有 Buffer" })

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

map("n", "<leader>cf", function()
    local ok, conform = pcall(require, "conform")
    if not ok then
        vim.notify("[GeoVim] conform.nvim 未加载，尝试使用 LSP 格式化", vim.log.levels.WARN)
        local success, err = pcall(vim.lsp.buf.format, { async = true })
        if not success then
            vim.notify("[GeoVim] LSP 格式化也失败了: " .. tostring(err), vim.log.levels.ERROR)
        end
        return
    end
    local success, err = pcall(conform.format, { async = true, lsp_fallback = true })
    if not success then
        vim.notify("[GeoVim] 格式化失败: " .. tostring(err), vim.log.levels.ERROR)
    end
end, { desc = "格式化当前文件" })

-- ============================================
-- 八、诊断跳转（全局可用，不限于 LSP 场景）
-- ============================================

map("n", "[d", function()
    local ok, err = pcall(vim.diagnostic.goto_prev, { float = true })
    if not ok then
        vim.notify("[GeoVim] 诊断跳转失败: " .. tostring(err), vim.log.levels.WARN)
    end
end, { desc = "上一个诊断" })

map("n", "]d", function()
    local ok, err = pcall(vim.diagnostic.goto_next, { float = true })
    if not ok then
        vim.notify("[GeoVim] 诊断跳转失败: " .. tostring(err), vim.log.levels.WARN)
    end
end, { desc = "下一个诊断" })

map("n", "<leader>d", vim.diagnostic.open_float, { desc = "查看当前诊断详情" })

-- ============================================
-- 九、Markdown
-- ============================================

-- <leader>mp 浏览器 Markdown 预览 → 定义在 lua/plugins/markdown.lua 的 keys 字段中

-- ============================================
-- 十、HTML 浏览器预览
-- ============================================
-- 按 <leader>hp 用系统默认浏览器打开当前 HTML 文件
-- 底层使用 Neovim 内置的 vim.ui.open()，自动适配 macOS/Linux/Windows

map("n", "<leader>hp", function()
    local filepath = vim.fn.expand("%:p")
    if vim.bo.filetype ~= "html" then
        vim.notify("[GeoVim] 当前不是 HTML 文件，无法预览", vim.log.levels.WARN)
        return
    end
    local ok, err = pcall(vim.ui.open, filepath)
    if not ok then
        vim.notify("[GeoVim] 打开浏览器失败: " .. tostring(err), vim.log.levels.ERROR)
    end
end, { desc = "在浏览器中预览 HTML" })

-- ============================================
-- 十一、杂项小优化
-- ============================================

-- 按 Esc 清除搜索高亮
map("n", "<Esc>", "<cmd> noh <cr>", { desc = "清除搜索高亮" })

-- 翻页后光标保持在屏幕中间
map("n", "<C-d>", "<C-d>zz", { desc = "向下翻页并居中" })
map("n", "<C-u>", "<C-u>zz", { desc = "向上翻页并居中" })

-- Visual 模式下缩进后保持选中
map("v", "<", "<gv", { desc = "向左缩进并保持选中" })
map("v", ">", ">gv", { desc = "向右缩进并保持选中" })

-- 终端模式下按 Esc 快速回到 Normal 模式（方便切窗口）
map("t", "<Esc>", "<C-\\><C-n>", { desc = "退出终端模式" })

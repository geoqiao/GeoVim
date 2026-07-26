-- ============================================
-- 快捷键映射 (Keymaps) —— 纯粹 Vim 原生风格
-- ============================================
-- 设计原则：
-- 1. 完全尊重 Vim 原生按键逻辑，不覆盖任何经典的 hjkl/0$ggG/uCtrl+r/fFtT; 等
-- 2. 所有高级功能统一放在 <leader>（空格）二级菜单下，配合 which-key 提示
-- 3. 复制、移动、选中、跳转全部使用 Vim 原生方式（y/d/c/f/t/0$^ggG 等）

local map = vim.keymap.set
local project = require("project")

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

local function rooted_telescope(picker)
    return function()
        local ok, builtin = pcall(require, "telescope.builtin")
        if not ok then
            vim.notify("[GeoVim] Telescope 加载失败", vim.log.levels.ERROR)
            return
        end
        builtin[picker]({ cwd = project.current() })
    end
end

map("n", "<leader>ff", rooted_telescope("find_files"), { desc = "在项目中查找文件" })
map("n", "<leader>fw", rooted_telescope("live_grep"), { desc = "在项目中全文搜索" })
map("n", "<leader>fb", "<cmd> Telescope buffers <cr>", { desc = "查找已打开的 Buffer" })
map("n", "<leader>fo", "<cmd> Telescope oldfiles <cr>", { desc = "最近打开的文件" })
map("n", "<leader>fh", "<cmd> Telescope help_tags <cr>", { desc = "搜索帮助文档" })
map("n", "<leader>fk", "<cmd> Telescope keymaps <cr>", { desc = "搜索快捷键" })
map("n", "<leader>fc", rooted_telescope("grep_string"), { desc = "在项目中搜索光标单词" })
map("n", "<leader>fi", "<cmd> Telescope current_buffer_fuzzy_find <cr>", { desc = "当前 Buffer 模糊查找" })

-- ============================================
-- 四、文件树
-- ============================================

map("n", "<leader>ee", function()
    vim.cmd("NvimTreeToggle " .. vim.fn.fnameescape(project.current()))
end, { desc = "显示/隐藏项目文件树" })

map("n", "<leader>eo", function()
    local ok, api = pcall(require, "nvim-tree.api")
    if not ok then
        vim.notify("[GeoVim] nvim-tree 加载失败", vim.log.levels.ERROR)
        return
    end
    if api.tree.is_visible() then
        api.tree.focus()
    else
        api.tree.open({ path = project.current() })
    end
end, { desc = "聚焦项目文件树" })

-- ============================================
-- 五、文件路径复制
-- ============================================

map("n", "<leader>cp", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    vim.notify("已复制绝对路径: " .. path)
end, { desc = "复制文件绝对路径" })

map("n", "<leader>cP", function()
    local path = vim.fn.expand("%")
    vim.fn.setreg("+", path)
    vim.notify("已复制相对路径: " .. path)
end, { desc = "复制文件相对路径" })

map("n", "<leader>cd", function()
    local dir = vim.fn.expand("%:p:h")
    vim.fn.setreg("+", dir)
    vim.notify("已复制所在目录: " .. dir)
end, { desc = "复制文件所在目录" })

-- ============================================
-- 六、Buffer 管理
-- ============================================
-- 使用 <leader>b 分组，恢复 H / L 的原生屏幕导航功能。

map("n", "<leader>bn", "<cmd> bnext <cr>", { desc = "下一个 Buffer" })
map("n", "<leader>bp", "<cmd> bprevious <cr>", { desc = "上一个 Buffer" })
map("n", "<leader>bd", "<cmd> bdelete <cr>", { desc = "关闭当前 Buffer" })
map("n", "<leader>bD", function()
    local current = vim.api.nvim_get_current_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
            vim.api.nvim_buf_delete(buf, { force = false })
        end
    end
end, { desc = "关闭其他所有 Buffer" })

-- ============================================
-- 七、窗口分屏管理
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
-- 八、格式化
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
    -- conform 0.7+ 已用 lsp_format = "fallback" 取代旧字段 lsp_fallback = true
    local success, err = pcall(conform.format, { async = true, lsp_format = "fallback" })
    if not success then
        vim.notify("[GeoVim] 格式化失败: " .. tostring(err), vim.log.levels.ERROR)
    end
end, { desc = "格式化当前文件" })

-- ============================================
-- 九、诊断跳转（全局可用，不限于 LSP 场景）
-- ============================================

-- vim.diagnostic.goto_prev / goto_next 已在 Neovim 0.11 弃用，新 API 是 vim.diagnostic.jump。
-- jump 内部带防御性检查，无需再用 pcall 包裹。
map("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "上一个诊断" })

map("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "下一个诊断" })

-- 用 <leader>de 代替原先的 <leader>d，避免 which-key 把 d 当作前缀组时与单动作冲突。
map("n", "<leader>de", vim.diagnostic.open_float, { desc = "查看当前诊断详情" })

-- ============================================
-- 十、Markdown
-- ============================================

-- <leader>mp 浏览器 Markdown 预览 → 定义在 lua/plugins/markdown.lua 的 keys 字段中

-- ============================================
-- 十一、HTML 浏览器预览
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
-- 十二、杂项小优化
-- ============================================

-- 按 Esc 清除搜索高亮
map("n", "<Esc>", "<cmd> noh <cr>", { desc = "清除搜索高亮" })

-- 翻页后光标保持在屏幕中间
map("n", "<C-d>", "<C-d>zz", { desc = "向下翻页并居中" })
map("n", "<C-u>", "<C-u>zz", { desc = "向上翻页并居中" })

-- Visual 模式下缩进后保持选中
map("v", "<", "<gv", { desc = "向左缩进并保持选中" })
map("v", ">", ">gv", { desc = "向右缩进并保持选中" })

-- 单次 Esc 保留给 Pi / Claude 等终端 TUI；连续按两次才回到 Normal 模式。
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "退出终端模式" })

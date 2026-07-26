-- ============================================
-- pi-nvim：在 Neovim 中集成 pi coding agent
-- ============================================
-- pi 在另一个终端里运行，本插件通过 unix socket 把编辑器上下文
-- （当前文件 / 选区 / buffer）作为 prompt 发送给正在跑的 pi session。
--
-- 前置条件：
--   1. 已安装 pi coding agent（pi 在 PATH 中）
--   2. pi 侧已装 pi-nvim extension（pi install npm:pi-nvim），
--      pi 启动时会自动在 /tmp/pi-nvim-sockets/ 下开 socket
--
-- 快捷键（<leader>p 前缀，见 which-key 的 Pi 分组）：
--   <leader>pp  打开发送对话框（normal / visual 通用）
--   <leader>pf  发送当前文件路径 + prompt
--   <leader>ps  发送 visual 选区 + prompt
--   <leader>pb  发送整个 buffer + prompt
--   <leader>pi  检查 pi 是否可达（ping）
--   <leader>pS  列出 / 切换正在运行的 pi session

return {
    {
        "carderne/pi-nvim",
        cmd = { "Pi", "PiSend", "PiSendFile", "PiSendSelection", "PiSendBuffer", "PiPing", "PiSessions" },
        -- 用 keys = {} 声明懒加载触发键，按下时 lazy.nvim 才真正 require 插件，
        -- 避免启动时就把 pi-nvim 加载进来。插件加载后会创建同名 user command。
        keys = {
            { "<leader>pp", "<cmd>Pi<cr>", desc = "Pi: 发送对话框" },
            -- Visual 模式必须通过 : 命令离开选区，让 Neovim 写入 '< 和 '> marks 并传递 command range。
            { "<leader>pp", ":Pi<cr>", desc = "Pi: 发送选区对话框", mode = "v" },
            { "<leader>pf", "<cmd>PiSendFile<cr>", desc = "Pi: 发送当前文件" },
            { "<leader>ps", ":PiSendSelection<cr>", desc = "Pi: 发送选区", mode = "v" },
            { "<leader>pb", "<cmd>PiSendBuffer<cr>", desc = "Pi: 发送整个 buffer" },
            { "<leader>pi", "<cmd>PiPing<cr>", desc = "Pi: 检查连接" },
            { "<leader>pS", "<cmd>PiSessions<cr>", desc = "Pi: 列出 / 切换 session" },
        },
        config = function()
            -- 如果系统未安装 pi 命令，给出提示并跳过配置
            if vim.fn.executable("pi") ~= 1 then
                vim.notify(
                    "[GeoVim] 未在 PATH 中找到 pi 命令，<leader>p 开头的 Pi 命令已禁用",
                    vim.log.levels.WARN
                )
                return
            end

            require("pi-nvim").setup({
                socket_path = nil, -- 自动发现 /tmp/pi-nvim-sockets/ 下匹配 cwd 的 session
                set_default_keymaps = false, -- 用上面 keys = {} 声明的映射，与 which-key 分组保持一致
            })
        end,
    },
}

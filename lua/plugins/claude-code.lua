-- ============================================
-- Claude Code：在 Neovim 中集成 Claude Code CLI
-- ============================================
-- 按 <leader>ac 在当前项目底部打开 Claude Code 终端面板，
-- 按 <leader>aC 继续上次对话，<leader>aR 选择历史对话。
-- Claude Code 修改的文件会自动刷新到 Neovim 缓冲区中。

return {
    {
        "greggh/claude-code.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume", "ClaudeCodeVerbose" },
        -- 用 keys = {} 声明懒加载触发键,这样按 <leader>ac 时 lazy.nvim 才真正 require 插件,
        -- 避免启动时就把 plenary / claude-code 全链路加载进来。插件自己的 setup() 会在加载后
        -- 注册同名键位,覆盖这里的 stub。
        keys = {
            { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "切换 Claude Code 面板" },
            { "<leader>aC", "<cmd>ClaudeCodeContinue<cr>", desc = "继续上次 Claude 对话" },
            { "<leader>aR", "<cmd>ClaudeCodeResume<cr>", desc = "选择历史 Claude 对话" },
            { "<leader>aV", "<cmd>ClaudeCodeVerbose<cr>", desc = "Claude Verbose 模式" },
        },
        config = function()
            -- 如果系统未安装 claude 命令，给出提示并跳过配置
            if vim.fn.executable("claude") ~= 1 then
                vim.notify(
                    "[GeoVim] Claude CLI 未找到，<leader>a 开头的 Claude 命令已禁用",
                    vim.log.levels.WARN
                )
                return
            end

            require("claude-code").setup({
                -- 命令路径（claude 命令必须已在 PATH 中）
                command = "claude",

                -- 终端窗口设置
                window = {
                    split_ratio = 0.5, -- 占用 50% 的屏幕宽度
                    position = "vertical", -- 左侧垂直分屏打开
                    enter_insert = true, -- 打开后自动进入插入模式
                    hide_numbers = true, -- 隐藏行号
                    hide_signcolumn = true, -- 隐藏 signcolumn
                },

                -- 文件自动刷新：Claude Code 修改文件后，Neovim 自动重载
                refresh = {
                    enable = true,
                    -- 不再覆盖全局 updatetime（默认 4000ms 即可,timer_interval 已每 5s 主动轮询）。
                    -- 早期版本默认 100ms 会拉低 CursorHold 触发阈值并增加 swap 写入频率,属于副作用。
                    timer_interval = 5000, -- 降低轮询频率，减少后台开销
                    show_notifications = false, -- 避免弹窗轰炸
                },

                -- Git 项目设置
                git = {
                    use_git_root = true, -- 在 git 项目里自动把 CWD 切到项目根目录
                },

                -- 扩展命令参数
                command_variants = {
                    continue = "--continue",
                    resume = "--resume",
                    verbose = "--verbose",
                },

                -- 键位映射
                keymaps = {
                    toggle = {
                        normal = "<leader>ac",
                        terminal = "<leader>ac",
                        variants = {
                            continue = "<leader>aC",
                            resume = "<leader>aR",
                            verbose = "<leader>aV",
                        },
                    },
                    window_navigation = true, -- 在 Claude Code 终端里可用 <C-h/j/k/l> 切窗口
                    scrolling = true, -- 在 Claude Code 终端里可用 <C-f/b> 翻页
                },
            })
        end,
    },
}

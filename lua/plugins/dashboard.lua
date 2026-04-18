-- ============================================
-- Dashboard：启动页 / 欢迎页
-- ============================================
-- 类似 NvChad 的开始页面，有大号 ASCII Logo、快捷按钮和最近文件列表。
-- 按 `e` 直接新建文件，按 `f` 打开查找，`r` 看最近文件等。

return {
    {
        "nvimdev/dashboard-nvim",
        lazy = false, -- 确保在 UIEnter 前加载完毕，:Dashboard 命令可用
        priority = 900, -- 比主题低一点，但足够早
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            -- 每日名言池
            local quotes = {
                "Talk is cheap. Show me the code. — Linus Torvalds",
                "Simplicity is the soul of efficiency. — Austin Freeman",
                "Code is like humor. When you have to explain it, it's bad. — Cory House",
                "First, solve the problem. Then, write the code. — John Johnson",
                "Experience is the name everyone gives to their mistakes. — Oscar Wilde",
                "Make it work, make it right, make it fast. — Kent Beck",
                "Clean code always looks like it was written by someone who cares. — Robert C. Martin",
                "The only way to learn a new programming language is by writing programs in it. — Dennis Ritchie",
                "Programming isn't about what you know; it's about what you can figure out. — Chris Pine",
                "Any fool can write code that a computer can understand. Good programmers write code that humans can understand. — Martin Fowler",
            }
            -- 初始化随机种子（LuaJIT 兼容；Lua 5.4 中 randomseed 行为不同但不影响此处）
            math.randomseed(os.time())
            local quote = quotes[math.random(#quotes)]

            -- Neovim 版本信息
            local ver = vim.version()
            local ver_str = string.format("v%d.%d.%d", ver.major, ver.minor, ver.patch)
            local datetime_str = os.date("%Y-%m-%d %H:%M")

            require("dashboard").setup({
                theme = "hyper", -- hyper = Logo + 快捷按钮 + 最近项目（最像 NvChad）
                config = {
                    -- Header: Block ASCII art spelling GEOVIM
                    header = {
                        "                                              ",
                        " ██████  ███████  ██████   ██    ██ ██ ███    ███ ",
                        "██       ██      ██    ██  ██    ██ ██ ████  ████ ",
                        "██   ███ █████   ██    ██  ██    ██ ██ ██ ████ ██ ",
                        "██    ██ ██      ██    ██   ██  ██  ██ ██  ██  ██ ",
                        " ██████  ███████  ██████     ████   ██ ██      ██ ",
                        "                                              ",
                        "        ⚡ GeoVim — Code at the speed of thought",
                        "                                              ",
                        "  " .. datetime_str .. "  |  Neovim " .. ver_str,
                        "                                              ",
                    },

                    -- Shortcuts: icon + label + key hint + command
                    shortcut = {
                        { desc = "  New file", group = "DashboardShortCut", key = "e", action = "enew" },
                        {
                            desc = "  Find file",
                            group = "DashboardShortCut",
                            key = "f",
                            action = "Telescope find_files",
                        },
                        {
                            desc = "  Recent files",
                            group = "DashboardShortCut",
                            key = "r",
                            action = "Telescope oldfiles",
                        },
                        {
                            desc = "  Find text",
                            group = "DashboardShortCut",
                            key = "g",
                            action = "Telescope live_grep",
                        },
                        { desc = "  Plugins", group = "DashboardShortCut", key = "l", action = "Lazy" },
                        { desc = "  Tools", group = "DashboardShortCut", key = "m", action = "Mason" },
                        { desc = "  Quit", group = "DashboardShortCut", key = "q", action = "qa" },
                    },

                    -- Recent projects list (hyper theme feature)
                    project = {
                        enable = true,
                        limit = 8,
                        icon = "󰂠 ",
                        label = " Recent Projects",
                        action = "Telescope find_files cwd=",
                    },

                    -- Footer: daily quote
                    footer = {
                        "",
                        quote,
                    },
                },
                hide = {
                    statusline = false, -- 保留状态栏
                    tabline = false, -- 保留 Tab 栏
                    winbar = false,
                },
            })

            -- 兼容透明背景：让 Dashboard 的各个区域也透明
            vim.api.nvim_set_hl(0, "DashboardHeader", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "DashboardCenter", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "DashboardFooter", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "DashboardProjectTitle", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "DashboardProjectIcon", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "DashboardMruTitle", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "DashboardShortCut", { bg = "NONE" })

            -- ============================================================
            -- 自己接管自动显示逻辑（不依赖 dashboard-nvim 内部的 UIEnter 条件）
            -- ============================================================
            vim.api.nvim_create_autocmd("UIEnter", {
                once = true,
                nested = true,
                callback = function()
                    -- 跳过从 stdin 启动的情况（例如 cat file | nvim -）
                    for _, v in pairs(vim.v.argv) do
                        if v == "-" then
                            return
                        end
                    end

                    local argc = vim.fn.argc()
                    local bufname = vim.api.nvim_buf_get_name(0)
                    local is_empty = argc == 0 and bufname == ""
                    local is_dir = argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1

                    if is_empty or is_dir then
                        if is_dir then
                            -- 目录启动时先把参数清掉，再切到目录
                            vim.cmd("cd " .. vim.fn.fnameescape(vim.fn.argv(0)))
                            vim.cmd("1argd")
                            vim.cmd("enew")
                        end
                        -- 使用插件的公共命令显示 dashboard，不依赖内部 API
                        vim.cmd("Dashboard")
                    end
                end,
            })
        end,
    },
}

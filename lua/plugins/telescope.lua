-- ============================================
-- Telescope：模糊搜索神器
-- ============================================
-- 功能包括：查找文件、全局搜索文本、查找 Buffer、搜索帮助文档等。
-- 它是 Neovim 生态中最受欢迎的搜索插件，相当于 VS Code 的 Ctrl+P 和 Ctrl+Shift+F。

return {
    {
        "nvim-telescope/telescope.nvim",
        event = "VeryLazy",
        dependencies = {
            -- Telescope 依赖的工具库
            "nvim-lua/plenary.nvim",
            -- 一个小优化：让文件搜索时使用原生 fzf 排序算法，速度更快
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    prompt_prefix = "   ", -- 搜索框前面的图标
                    selection_caret = " ", -- 选中项前面的图标
                    path_display = { "smart" }, -- 路径显示方式：智能截断
                    file_ignore_patterns = {
                        "node_modules",
                        ".git/",
                        ".venv/",
                        "__pycache__/",
                        ".mypy_cache/",
                    },
                    mappings = {
                        i = {
                            -- Insert 模式下按 Esc 进入 Telescope Normal 模式（Vim 原生模态一致性）
                            -- 如需快速关闭，请用 Ctrl+c
                            -- ["<Esc>"] = require("telescope.actions").close, -- 已删除，恢复默认行为
                            -- Ctrl+j/k 在结果列表中上下移动
                            ["<C-j>"] = require("telescope.actions").move_selection_next,
                            ["<C-k>"] = require("telescope.actions").move_selection_previous,
                        },
                    },
                },
                pickers = {
                    find_files = {
                        hidden = true, -- 搜索时包含隐藏文件
                    },
                    live_grep = {
                        additional_args = function()
                            return { "--hidden" }
                        end,
                    },
                },
            })
            -- 加载 fzf 扩展
            pcall(telescope.load_extension, "fzf")
        end,
    },
}

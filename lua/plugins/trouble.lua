-- ============================================
-- Trouble：诊断列表与符号导航
-- ============================================
-- 把 LSP / nvim-lint 诊断、文档符号、Quickfix 和 TODO 聚合到可交互面板中。
-- Trouble 只负责展示和跳转，诊断数据仍由 LSP、nvim-lint、todo-comments 等来源提供。

return {
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "诊断列表 (Trouble)" },
            {
                "<leader>xb",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "当前 Buffer 诊断",
            },
            {
                "<leader>xs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "符号列表 (Symbols)",
            },
            {
                "<leader>xl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP 定义/引用",
            },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix 列表" },
            {
                "<leader>xt",
                function()
                    -- 启动页没有 BufReadPre，需先显式加载 todo-comments 才能注册 Trouble source。
                    require("lazy").load({ plugins = { "todo-comments.nvim" } })
                    -- todo-comments 在 VimEnter 前加载时会 defer setup；同样 defer，确保其先完成初始化。
                    vim.defer_fn(function()
                        vim.cmd("Trouble todo toggle")
                    end, 0)
                end,
                desc = "TODO 列表",
            },
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            auto_close = false,
            auto_preview = true,
            multiline = true,
            win = {
                position = "bottom",
                size = 10,
            },
        },
    },
}

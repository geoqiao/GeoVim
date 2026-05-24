-- ============================================
-- Trouble：诊断列表与符号导航
-- ============================================
-- 比原生 quickfix 更美观的诊断/符号聚合面板。
-- 支持按文件、severity 分组，可配合 Telescope 和 todo-comments 使用。

return {
    {
        "folke/trouble.nvim",
        cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            position = "bottom",
            height = 10,
            width = 50,
            icons = true,
            mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
            severity = nil, -- nil = 所有 severity
            fold_open = "",
            fold_closed = "",
            group = true,
            padding = true,
            cycle_results = true,
            action_keys = {
                close = "q",
                cancel = "<esc>",
                refresh = "r",
                jump = { "<cr>", "<tab>", "<2-leftmouse>" },
                open_split = { "<c-x>" },
                open_vsplit = { "<c-v>" },
                open_tab = { "<c-t>" },
                jump_close = { "o" },
                toggle_mode = "m",
                switch_severity = "s",
                toggle_preview = "P",
                hover = "K",
                preview = "p",
                close_folds = { "zM", "zm" },
                open_folds = { "zR", "zr" },
                toggle_fold = { "zA", "za" },
                previous = "k",
                next = "j",
                help = "?",
            },
            multiline = true,
            indent_lines = true,
            win_config = { border = "rounded" },
            auto_open = false, -- 不自动打开
            auto_close = false, -- 诊断解决后不自动关闭
            auto_preview = true,
            auto_fold = false,
            auto_jump = { "lsp_definitions" }, -- 仅在查看定义时自动跳转
            include_declaration = { "lsp_references", "lsp_implementations", "lsp_definitions" },
            signs = {
                error = " ",
                warning = " ",
                hint = "󰌶 ",
                information = " ",
                other = " ",
            },
            use_diagnostic_signs = true,
        },
        config = function(_, opts)
            require("trouble").setup(opts)

            -- 快捷键： leader + x 开头
            vim.keymap.set(
                "n",
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                { desc = "诊断列表 (Trouble)" }
            )
            vim.keymap.set(
                "n",
                "<leader>xb",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                { desc = "当前 Buffer 诊断" }
            )
            vim.keymap.set(
                "n",
                "<leader>xs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                { desc = "符号列表 (Symbols)" }
            )
            vim.keymap.set(
                "n",
                "<leader>xl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                { desc = "LSP 定义/引用" }
            )
            vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix 列表" })
            vim.keymap.set("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "TODO 列表" })
        end,
    },
}

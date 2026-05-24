-- ============================================
-- Todo Comments：高亮 TODO / FIXME / HACK 等注释
-- ============================================
-- 自动识别代码注释中的 TODO、FIXME、HACK、NOTE 等关键字，
-- 用不同颜色高亮显示。配合 Trouble 可集中查看所有 TODO。

return {
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            signs = true, -- 在左侧 signcolumn 显示图标
            sign_priority = 8,
            keywords = {
                FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
                TODO = { icon = " ", color = "info" },
                HACK = { icon = " ", color = "warning" },
                WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                PERF = { icon = " ", color = "hint", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
                TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
            },
            highlight = {
                multiline = true,
                multiline_pattern = "^.",
                multiline_context = 10,
                before = "", -- "fg" or "bg" or empty
                keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty
                after = "fg", -- "fg" or "bg" or empty
                pattern = [[.*<(KEYWORDS)\s*:]],
                comments_only = true,
                max_line_len = 400,
                exclude = {},
            },
            colors = {
                error = { "DiagnosticError", "ErrorMsg", "#E06C75" },
                warning = { "DiagnosticWarn", "WarningMsg", "#FFC66D" },
                info = { "DiagnosticInfo", "#6897BB" },
                hint = { "DiagnosticHint", "#4FC3A1" },
                default = { "Identifier", "#CC7832" },
                test = { "Identifier", "#A8C66C" },
            },
        },
    },
}

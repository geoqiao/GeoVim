-- ============================================
-- Comment.nvim：快速注释代码
-- ============================================
-- 支持 gcc（单行注释）、gc（选中注释）、gb（块注释）等。
-- 默认映射：gcc（单行注释）、gc（Visual 注释）、gbc（块注释）。

return {
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            toggler = {
                line = "gcc",
                block = "gbc",
            },
            opleader = {
                line = "gc",
                block = "gb",
            },
        },
    },
}

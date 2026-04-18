-- ============================================
-- 自动括号配对
-- ============================================
-- 输入 ( 时自动变成 ()，光标留在中间。
-- 输入 ) 时如果后面已经有 )，会智能跳过而不是重复插入。
-- 同样适用于 {}、[]、""、''、``。

return {
    {
        "echasnovski/mini.pairs",
        event = "InsertEnter",
        config = function()
            require("mini.pairs").setup({
                -- 只在插入模式下生效
                modes = { insert = true, command = false, terminal = false },
                -- 跳过配对的条件：如果下一个字符是非空白字符（如单词、数字等），
                -- 就不自动插入配对括号，避免在已有代码中间插入时造成混乱
                skip_next = [=[[%w%%%'%[%)%]]=],
                -- 跳过配对的条件：如果在 treesitter 的某些节点类型中（如 string、comment），
                -- 不自动配对，避免在字符串或注释里误触发
                skip_ts = { "string" },
                -- 跳过配对的条件：如果当前行只包含空白字符，不自动配对
                skip_unbalanced = true,
                -- 在特定文件类型中完全禁用
                -- markdown 中禁用 ` 配对，避免与代码块标记冲突
                markdown = true,
            })
        end,
    },
}

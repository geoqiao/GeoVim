-- ============================================
-- 自动括号配对
-- ============================================
-- 输入 ( 时自动变成 ()，光标留在中间；输入已有的右括号时会直接跳过。
-- Markdown / Vimwiki 中保留反引号的原生输入，避免与代码块标记冲突。

return {
    {
        "echasnovski/mini.pairs",
        event = "InsertEnter",
        config = function()
            require("mini.pairs").setup({
                modes = { insert = true, command = false, terminal = false },
            })

            local function use_literal_backtick(bufnr)
                vim.keymap.set("i", "`", "`", {
                    buffer = bufnr,
                    desc = "插入反引号（Markdown）",
                })
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("minipairs_markdown", { clear = true }),
                pattern = { "markdown", "vimwiki" },
                callback = function(args)
                    use_literal_backtick(args.buf)
                end,
            })

            -- 插件通常在当前 buffer 第一次进入 Insert 模式时加载，此时 FileType 事件已经发生。
            if vim.list_contains({ "markdown", "vimwiki" }, vim.bo.filetype) then
                use_literal_backtick(0)
            end
        end,
    },
}

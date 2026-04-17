-- ============================================
-- Bufferline：顶部的“标签页”栏
-- ============================================
-- 像浏览器标签页一样显示你打开的文件，支持鼠标点击切换和关闭。

return {
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("bufferline").setup({
                options = {
                    -- 使用 Neovim 内置的缓冲区编号作为标签名
                    numbers = "ordinal",
                    -- 关闭按钮显示在右侧
                    close_command = "bdelete! %d",
                    right_mouse_command = "bdelete! %d",
                    -- 标签页过多时的显示模式
                    offsets = {
                        {
                            filetype = "NvimTree",
                            text = "File Explorer",
                            text_align = "center",
                            separator = true,
                        },
                    },
                    -- 图标和颜色配置
                    diagnostics = "nvim_lsp",
                    diagnostics_indicator = function(count, level)
                        local icon = level:match("error") and " " or " "
                        return " " .. icon .. count
                    end,
                    -- 排序方式：按打开的顺序
                    sort_by = "insert_after_current",
                },
            })
        end,
    },
}

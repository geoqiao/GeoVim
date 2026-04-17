-- ============================================
-- Which-Key：快捷键提示助手
-- ============================================
-- 当你按了 <leader>（空格键）或其他前缀键后，屏幕下方会弹出一个提示面板，
-- 告诉你接下来可以按什么键。对新手极其友好！

return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup({
                preset = "modern",
                delay = 250, -- 按键后 250ms 再弹出提示
                -- timeoutlen 已在 options.lua 中设置，此处无需重复
                triggers = {
                    { "<auto>", mode = "nixsotc" },
                },
                icons = {
                    mappings = false, -- 不使用图标，纯文字对新手更直观
                },
            })

            -- 注册常用的前缀分组
            require("which-key").add({
                { "<leader>a", group = "AI (Claude)" },
                { "<leader>b", group = "Buffer" },
                { "<leader>h", group = "HTML" },
                { "<leader>c", group = "Code Action" },
                { "<leader>d", group = "Diagnostics" },
                { "<leader>e", group = "Explorer" },
                { "<leader>f", group = "Find / Search" },
                { "<leader>g", group = "Git" },
                { "<leader>m", group = "Markdown" },
                { "<leader>s", group = "Split" },
                { "<leader>y", group = "System Clipboard" },
            })
        end,
    },
}

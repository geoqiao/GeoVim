-- ============================================
-- Noice.nvim：美化通知、命令行和搜索框
-- ============================================
-- 把原生 vim.notify 的丑陋弹窗变成右下角平滑通知，
-- 同时接管命令行和搜索框的 UI，让整体视觉更统一。

return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        config = function()
            require("noice").setup({
                lsp = {
                    -- 用 noice 替代原生 LSP 的 hover/signature 弹窗
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                    },
                    hover = { enabled = true },
                    signature = { enabled = true },
                },
                presets = {
                    bottom_search = true, -- 搜索框放底部（像 VSCode）
                    command_palette = true, -- 命令行美化（: 命令）
                    long_message_to_split = true, -- 长消息自动转到 split
                    inc_rename = false,
                    lsp_doc_border = true, -- LSP 文档边框
                },
                -- 路由规则：过滤掉一些不需要的通知噪音
                routes = {
                    {
                        filter = {
                            event = "msg_show",
                            any = {
                                { find = "%d+L, %d+B" },
                                { find = "; after #%d+" },
                                { find = "; before #%d+" },
                                { find = "%d fewer lines" },
                                { find = "%d more lines" },
                            },
                        },
                        opts = { skip = true },
                    },
                    -- 让 "written" 等短消息用 mini 样式显示
                    {
                        filter = {
                            event = "msg_show",
                            kind = "",
                        },
                        opts = { replace = true },
                    },
                },
            })

            -- 配置 notify 的外观
            require("notify").setup({
                background_colour = "#000000",
                timeout = 3000,
                max_height = function()
                    return math.floor(vim.o.lines * 0.75)
                end,
                max_width = function()
                    return math.floor(vim.o.columns * 0.5)
                end,
                stages = "fade_in_slide_out",
                render = "compact",
            })
        end,
    },
}

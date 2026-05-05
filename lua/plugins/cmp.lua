-- ============================================
-- 补全引擎：blink.cmp
-- ============================================
-- blink.cmp 是用 Rust SIMD 实现的现代补全引擎，特点：
--   1. 单插件即可工作（不需要 cmp/luasnip/cmp-nvim-lsp 6 件套）
--   2. Rust 模糊匹配，比 telescope-fzf-native 还快
--   3. 内置 LSP / path / buffer / snippet 4 种 source
--   4. 启动延迟 < 1ms（InsertEnter 时才加载）
--
-- 与 LSP 的协作：
--   blink.get_lsp_capabilities() 返回 capabilities 表，
--   在 lsp.lua 中通过 vim.lsp.config('*', { capabilities = ... }) 注入到所有 server。

return {
    {
        "saghen/blink.cmp",
        version = "*", -- 用预编译的稳定 release，避免本地编译 Rust
        event = { "InsertEnter", "CmdlineEnter" },
        opts = {
            keymap = {
                preset = "default", -- C-y 接受 / C-n,C-p 切换 / C-Space 触发 / C-e 取消
            },

            appearance = {
                nerd_font_variant = "mono",
            },

            completion = {
                accept = {
                    auto_brackets = {
                        enabled = true, -- 接受函数补全时自动补 ()
                    },
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 200,
                },
                ghost_text = {
                    enabled = false, -- 关闭幽灵文字，避免视觉干扰
                },
                menu = {
                    border = "rounded",
                    draw = {
                        treesitter = { "lsp" }, -- 在补全菜单内用 TS 高亮代码片段
                    },
                },
            },

            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },

            signature = {
                enabled = true, -- 函数签名提示，打 ( 时自动浮现
                window = {
                    border = "rounded",
                },
            },

            fuzzy = {
                implementation = "prefer_rust_with_warning", -- 优先 Rust，fallback Lua 并警告
            },
        },
        opts_extend = { "sources.default" },
    },
}

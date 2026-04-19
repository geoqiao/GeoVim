-- ============================================
-- Image：在 Neovim 中显示图片
-- ============================================
-- 依赖终端支持 Kitty Graphics Protocol，Ghostty 原生支持。
-- 需要系统安装 ImageMagick（magick 或 convert 命令）。
--
-- 支持场景：
--   1. Markdown 文件内嵌图片实时预览
--   2. 直接打开图片文件（png/jpg/gif/webp/avif）时在 Buffer 中渲染
--   3. 在 nvim-tree 中按 <CR> 或 o 打开图片文件即可查看

return {
    {
        "3rd/image.nvim",
        event = "VeryLazy",
        config = function()
            require("image").setup({
                backend = "kitty", -- Ghostty 支持 Kitty 图像协议
                processor = "magick_cli", -- 使用 ImageMagick CLI，无需安装 LuaRock
                hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
                max_width_window_percentage = 100,  -- 直接打开图片时允许占满窗口宽度
                max_height_window_percentage = 90,  -- 高度最多占窗口 90%，留一点边距
                scale_factor = 1.0,                 -- 按原始比例显示，不额外缩小
                window_overlap_clear_enabled = true, -- 窗口重叠时自动隐藏图片，避免残影
                integrations = {
                    markdown = {
                        enabled = true,
                        clear_in_insert_mode = false,
                        download_remote_images = true,
                        -- 方案 A：默认渲染所有图片（适合短文档）
                        -- only_render_image_at_cursor = false,

                        -- 方案 B：仅当光标在图片链接上时才显示（推荐，避免大图片破坏排版）
                        only_render_image_at_cursor = true,
                        only_render_image_at_cursor_mode = "popup", -- "popup" 浮动预览 / "inline" 内联替换

                        filetypes = { "markdown", "vimwiki" },
                    },
                },
            })
        end,
    },
}

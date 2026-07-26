-- ============================================
-- Image：在 Neovim 中显示图片
-- ============================================
-- Ghostty 1.3.1 的 Kitty Graphics Protocol 实现有已知缺陷：
-- - "normal" 模式：完全不显示
-- - "unicode-placeholders" 模式：显示黑色方块
-- 根因不在 Neovim 配置，而在 Ghostty 对 Kitty 协议的渲染实现。
--
-- 解决方案：改用 sixel backend。Ghostty 对 Sixel 的支持更成熟稳定。
-- 已验证 ImageMagick 支持 Sixel 格式输出（magick -list format | grep sixel）。

return {
    {
        "3rd/image.nvim",
        ft = { "markdown", "vimwiki" },
        event = {
            {
                event = "BufReadPre",
                pattern = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
            },
        },
        config = function()
            require("image").setup({
                backend = "sixel",
                processor = "magick_cli",
                hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
                max_width_window_percentage = 100,
                max_height_window_percentage = 90,
                scale_factor = 1.0,
                window_overlap_clear_enabled = false,
                integrations = {
                    markdown = {
                        enabled = true,
                        clear_in_insert_mode = false,
                        download_remote_images = true,
                        only_render_image_at_cursor = true,
                        only_render_image_at_cursor_mode = "popup",
                        filetypes = { "markdown", "vimwiki" },
                    },
                },
            })
        end,
    },
}

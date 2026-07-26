-- ============================================
-- Image：在 Neovim 中显示图片
-- ============================================
-- Ghostty 不支持 Sixel，只支持 Kitty Graphics Protocol。
-- 使用 normal placement，避免 unicode-placeholders 在部分 Ghostty 版本中的尺寸问题。
-- processor 使用 ImageMagick CLI，无需安装 LuaRock。

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
                backend = "kitty",
                processor = "magick_cli",
                kitty_method = "normal",
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

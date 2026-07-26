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
            local function delete_buffer(bufnr)
                if not vim.api.nvim_buf_is_valid(bufnr) then
                    return
                end
                if vim.bo[bufnr].modified then
                    vim.notify("[GeoVim] Buffer 尚未保存，未执行关闭", vim.log.levels.WARN)
                    return
                end

                local ok, err = pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
                if not ok then
                    vim.notify("[GeoVim] Buffer 关闭失败: " .. tostring(err), vim.log.levels.WARN)
                end
            end

            require("bufferline").setup({
                highlights = {
                    fill = { bg = "NONE" },
                    background = { bg = "NONE" },
                    tab = { bg = "NONE" },
                    tab_selected = { bg = "NONE" },
                    tab_separator = { bg = "NONE" },
                    tab_separator_selected = { bg = "NONE" },
                    buffer_visible = { bg = "NONE" },
                    buffer_selected = { bg = "NONE" },
                    separator = { bg = "NONE" },
                    separator_selected = { bg = "NONE" },
                    separator_visible = { bg = "NONE" },
                    offset_separator = { bg = "NONE" },
                    close_button = { bg = "NONE" },
                    close_button_visible = { bg = "NONE" },
                    close_button_selected = { bg = "NONE" },
                    duplicate = { bg = "NONE" },
                    duplicate_selected = { bg = "NONE" },
                    duplicate_visible = { bg = "NONE" },
                    modified = { bg = "NONE" },
                    modified_selected = { bg = "NONE" },
                    modified_visible = { bg = "NONE" },
                    indicator_visible = { bg = "NONE" },
                    indicator_selected = { bg = "NONE" },
                    pick = { bg = "NONE" },
                    pick_selected = { bg = "NONE" },
                    pick_visible = { bg = "NONE" },
                },
                options = {
                    -- 使用 Neovim 内置的缓冲区编号作为标签名
                    numbers = "ordinal",
                    -- 关闭按钮显示在右侧；未保存的 Buffer 必须先保存或显式放弃修改
                    close_command = delete_buffer,
                    right_mouse_command = delete_buffer,
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

-- ============================================
-- Lualine：底部的状态栏
-- ============================================
-- 显示当前模式、文件路径、文件类型、行号/列号、Git 分支等信息。
-- 美观且实用，是 Neovim 的“仪表盘”。

return {
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "catppuccin-frappe", -- 与主题保持一致
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = {
                        statusline = { "NvimTree", "lazy" },
                    },
                    transparent = true, -- 状态栏背景透明
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = {
                        { "filename", path = 1 }, -- path=1 显示相对路径
                    },
                    lualine_x = {
                        "encoding",
                        "fileformat",
                        "filetype",
                    },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },
}

-- ============================================
-- 主题 Colorscheme (Neodarcula - PyCharm Darcula Style)
-- ============================================
-- Neodarcula 是 IntelliJ IDEA / PyCharm 默认 Darcula 主题的 Neovim 移植。
-- 特点：深灰背景 (#2B2B2B)、橙色关键字、黄色函数、绿色字符串。

return {
    {
        "pmouraguedes/neodarcula.nvim",
        lazy = false,
        priority = 1000,
        config = function(_, opts)
            require("neodarcula").setup(opts)
            vim.cmd("colorscheme neodarcula")

            -- 透明背景下，强制关键高亮组背景透明
            local transparent_groups = {
                "Normal",
                "NormalNC",
                "NormalFloat",
                "FloatBorder",
                "FloatTitle",
                "EndOfBuffer",
                "ColorColumn",
                "SignColumn",
                "LineNr",
                "CursorLineNr",
                "FoldColumn",
                "WinSeparator",
                "VertSplit",
                "StatusLine",
                "StatusLineNC",
                "TabLine",
                "TabLineFill",
                "Pmenu",
                "PmenuSel",
                "PmenuSbar",
                "PmenuThumb",
                "TelescopeNormal",
                "TelescopeBorder",
                "NvimTreeNormal",
                "NvimTreeNormalNC",
                "NvimTreeWinSeparator",
                -- Alpha 启动屏区域
                "AlphaHeader",
                "AlphaButtons",
                "AlphaShortcut",
                "AlphaFooter",
            }
            for _, group in ipairs(transparent_groups) do
                vim.api.nvim_set_hl(0, group, { bg = "NONE" })
            end

            -- ============================================
            -- Alpha 启动屏配色（搭配 Neodarcula 橙黄色调）
            -- ============================================
            -- AlphaHeader   橙色 #CC7832（Darcula 关键字色，logo 主色）
            -- AlphaButtons  黄色 #FFC66D（Darcula 函数色，按钮主标签）
            -- AlphaShortcut 暗灰 #6A6A6A（按钮右侧 hint，比 label 暗一档形成层级）
            -- AlphaFooter   灰色 #808080（低调说明）
            vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#CC7832", bg = "NONE", bold = true })
            vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#FFC66D", bg = "NONE" })
            vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#6A6A6A", bg = "NONE" })
            vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#808080", bg = "NONE", italic = true })
        end,
    },
}

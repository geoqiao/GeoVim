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
                -- Dashboard 区域
                "DashboardHeader",
                "DashboardCenter",
                "DashboardFooter",
                "DashboardProjectTitle",
                "DashboardProjectIcon",
                "DashboardMruTitle",
                "DashboardShortCut",
            }
            for _, group in ipairs(transparent_groups) do
                vim.api.nvim_set_hl(0, group, { bg = "NONE" })
            end
        end,
    },
}

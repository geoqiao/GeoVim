-- ============================================
-- 主题 Colorscheme（Neodarcula + Aurora 高亮覆盖）
-- ============================================
-- Neodarcula 是 IntelliJ IDEA / PyCharm 默认 Darcula 主题的 Neovim 移植。
-- 特点：深灰背景 (#2B2B2B)、橙色关键字、黄色函数、绿色字符串。
--
-- Aurora 是这套配置的 UI 配色补充层，用 lua/palette.lua 定义的语义色
-- 重写了启动屏（Alpha）与命令行（Noice）的高亮组，让它们与 Neodarcula
-- 的橙黄主调形成统一观感。状态栏（Lualine）的颜色独立在 lualine.lua 中处理。

return {
    {
        "pmouraguedes/neodarcula.nvim",
        lazy = false,
        priority = 1000,
        config = function(_, opts)
            require("neodarcula").setup(opts)
            vim.cmd("colorscheme neodarcula")

            local p = require("palette")

            -- ============================================
            -- 透明背景：强制以下高亮组的 bg 为 NONE
            -- ============================================
            -- 注意：AlphaShortcut 现在是 chip 风格（带背景），不在此列。
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
                -- Alpha 启动屏的纯文字区域（按钮 label / footer 等）
                "AlphaHeader",
                "AlphaButtons",
                "AlphaFooter",
                "AlphaTagline",
                "AlphaSectionLabel",
            }
            for _, group in ipairs(transparent_groups) do
                vim.api.nvim_set_hl(0, group, { bg = "NONE" })
            end

            -- ============================================
            -- Alpha 启动屏配色（Aurora）
            -- ============================================
            -- AlphaHeader        Normal 模式钢蓝   logo 主体（与 lualine normal 模式同色）
            -- AlphaTagline       次级灰斜体        "Code at the speed of thought"
            -- AlphaSectionLabel  弱灰              "GET STARTED" / "TOOLS" 分组标题
            -- AlphaButtons       品牌黄            按钮主 label
            -- AlphaShortcut      chip 风格        暗灰文字 + 抬升面板背景，按钮右侧药丸
            -- AlphaFooter        弱灰斜体          底部启动统计
            vim.api.nvim_set_hl(0, "AlphaHeader", { fg = p.mode.normal, bg = "NONE", bold = true })
            vim.api.nvim_set_hl(0, "AlphaTagline", { fg = p.fg.secondary, bg = "NONE", italic = true })
            vim.api.nvim_set_hl(0, "AlphaSectionLabel", { fg = p.fg.muted, bg = "NONE", bold = true })
            vim.api.nvim_set_hl(0, "AlphaButtons", { fg = p.brand.yellow, bg = "NONE" })
            vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = p.fg.secondary, bg = p.bg.elevated })
            vim.api.nvim_set_hl(0, "AlphaFooter", { fg = p.fg.muted, bg = "NONE", italic = true })

            -- ============================================
            -- Noice 命令行 / 浮窗（Aurora）
            -- ============================================
            -- 给 :command_palette 的浮动命令行套上品牌橙边框，body 用抬升面板背景，
            -- 让命令行看起来像一片浮在编辑区上方的"控制台"。
            vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { fg = p.fg.primary, bg = p.bg.elevated })
            vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = p.brand.orange, bg = "NONE" })
            vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = p.brand.orange, bg = "NONE", bold = true })
            vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = p.brand.orange, bg = "NONE" })
            vim.api.nvim_set_hl(0, "NoiceCmdlineIconCmdline", { fg = p.brand.orange, bg = "NONE" })
            vim.api.nvim_set_hl(0, "NoiceCmdlineIconSearch", { fg = p.brand.yellow, bg = "NONE" })
            vim.api.nvim_set_hl(0, "NoiceCmdlinePrompt", { fg = p.fg.primary, bg = "NONE" })
            -- 不同模式下命令行边框的细分（搜索 / lua / help 等）
            vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderCmdline", { fg = p.brand.orange, bg = "NONE" })
            vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderSearch", { fg = p.brand.yellow, bg = "NONE" })
            vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderLua", { fg = p.mode.normal, bg = "NONE" })
            vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderHelp", { fg = p.mode.terminal, bg = "NONE" })
            -- 命令行补全弹窗
            vim.api.nvim_set_hl(0, "NoicePopupmenu", { fg = p.fg.primary, bg = p.bg.elevated })
            vim.api.nvim_set_hl(0, "NoicePopupmenuBorder", { fg = p.fg.subtle, bg = "NONE" })
            vim.api.nvim_set_hl(0, "NoicePopupmenuSelected", { fg = p.brand.orange, bg = p.bg.hover, bold = true })
            vim.api.nvim_set_hl(0, "NoicePopupmenuMatch", { fg = p.brand.yellow, bg = "NONE", bold = true })
        end,
    },
}

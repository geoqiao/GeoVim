-- ============================================
-- 主题 Colorscheme
-- ============================================
-- Catppuccin 是一套非常精致、低饱和的配色方案，
-- 有四种变体：latte（亮）、frappe（暗）、macchiato（更暗）、mocha（最暗）。

return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false, -- 不能懒加载，否则启动时界面会先闪一下默认色
        priority = 1000, -- 优先级设高，确保最先加载
        opts = {
            flavour = "frappe", -- 可选：latte, frappe, macchiato, mocha
            transparent_background = true,
            integrations = {
                -- 未安装 nvim-cmp，使用原生 vim.lsp.completion
                -- cmp = true,
                gitsigns = true,
                nvimtree = true,
                treesitter = true,
                telescope = true,
                mason = true,
                notify = true,
                mini = true,
                which_key = true,
                lsp_trouble = true,
                native_lsp = {
                    enabled = true,
                    virtual_text = {
                        errors = { "italic" },
                        hints = { "italic" },
                        warnings = { "italic" },
                        information = { "italic" },
                    },
                    underlines = {
                        errors = { "underline" },
                        hints = { "underline" },
                        warnings = { "underline" },
                        information = { "underline" },
                    },
                },
            },
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd("colorscheme catppuccin-frappe")

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
            }
            for _, group in ipairs(transparent_groups) do
                vim.api.nvim_set_hl(0, group, { bg = "NONE" })
            end
        end,
    },
}

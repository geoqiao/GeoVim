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
                cmp = true,
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

            -- 透明背景下，让 colorcolumn / signcolumn / 行号列也透明显示
            vim.api.nvim_set_hl(0, "ColorColumn", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE" })
        end,
    },
}

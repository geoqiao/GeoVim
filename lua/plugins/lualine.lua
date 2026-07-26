-- ============================================
-- Lualine：底部状态栏（Aurora 主题）
-- ============================================
-- 用 lua/palette.lua 中的语义色为 6 种 Vim 模式分别上色，
-- 中段（b/c/x/y）保持透明，让终端壁纸 / 主题透明效果继续穿透。
-- 模式段（a/z）用实色填充并加粗，与中段之间用 powerline 楔形过渡。

return {
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local p = require("palette")

            -- 每个模式用相同结构生成：a/z 实色，b/y 半透明文字，c/x 透明文字。
            local function mode_section(mode_color)
                return {
                    a = { fg = p.bg.base, bg = mode_color, gui = "bold" },
                    b = { fg = p.fg.primary, bg = "NONE" },
                    c = { fg = p.fg.secondary, bg = "NONE" },
                    x = { fg = p.fg.secondary, bg = "NONE" },
                    y = { fg = p.fg.primary, bg = "NONE" },
                    z = { fg = p.bg.base, bg = mode_color, gui = "bold" },
                }
            end

            local aurora_theme = {
                normal = mode_section(p.mode.normal),
                insert = mode_section(p.mode.insert),
                visual = mode_section(p.mode.visual),
                replace = mode_section(p.mode.replace),
                command = mode_section(p.mode.command),
                terminal = mode_section(p.mode.terminal),
                inactive = {
                    a = { fg = p.fg.muted, bg = "NONE" },
                    b = { fg = p.fg.muted, bg = "NONE" },
                    c = { fg = p.fg.subtle, bg = "NONE" },
                },
            }

            require("lualine").setup({
                options = {
                    theme = aurora_theme,
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = {
                        statusline = { "NvimTree", "lazy", "alpha" },
                    },
                    globalstatus = true,
                },
                sections = {
                    lualine_a = {
                        { "mode", fmt = string.upper },
                    },
                    lualine_b = {
                        { "branch", icon = "" },
                        {
                            "diff",
                            symbols = { added = " ", modified = " ", removed = " " },
                            colored = true,
                        },
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            sections = { "error", "warn", "info", "hint" },
                            symbols = { error = " ", warn = " ", info = " ", hint = "󰌶 " },
                            diagnostics_color = {
                                error = { fg = p.diag.error },
                                warn = { fg = p.diag.warn },
                                info = { fg = p.diag.info },
                                hint = { fg = p.diag.hint },
                            },
                        },
                    },
                    lualine_c = {
                        {
                            "filename",
                            path = 1, -- 相对路径
                            symbols = {
                                modified = " ●",
                                readonly = " ",
                                unnamed = "[No Name]",
                                newfile = "[New]",
                            },
                        },
                    },
                    lualine_x = {
                        "encoding",
                        "fileformat",
                        "filetype",
                    },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
                extensions = { "nvim-tree", "lazy" },
            })
        end,
    },
}

-- ============================================
-- Alpha：启动屏 / 欢迎页（替代 dashboard-nvim）
-- ============================================
-- 设计参考：LazyVim 早期版本 + NvChad nvdash 的 ANSI Shadow 字体大字。
-- logo 字体与 NvChad/LazyVim 一致，只把 NEOVIM 换成 GEOVIM，保持视觉熟悉度。
--
-- 显示场景：
--   1. nvim（无参数）
--   2. nvim 打开目录
--   3. 通过 stdin 输入

return {
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            -- ============================================
            -- ASCII Logo（ANSI Shadow，与 NvChad/LazyVim 同款字体）
            -- ============================================
            dashboard.section.header.val = {
                [[ ██████╗ ███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
                [[██╔════╝ ██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
                [[██║  ███╗█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
                [[██║   ██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
                [[╚██████╔╝███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
                [[ ╚═════╝ ╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
            }

            -- ============================================
            -- 快捷按钮（完全保留 dashboard.lua 中的 e/f/r/g/l/m/q）
            -- ============================================
            dashboard.section.buttons.val = {
                dashboard.button("e", "  New file", "<cmd>ene <BAR> startinsert<CR>"),
                dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
                dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
                dashboard.button("g", "  Find text", "<cmd>Telescope live_grep<CR>"),
                dashboard.button("l", "󰒲  Lazy", "<cmd>Lazy<CR>"),
                dashboard.button("m", "  Mason", "<cmd>Mason<CR>"),
                dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
            }

            -- ============================================
            -- Footer：启动统计（loaded plugins + startup time）
            -- ============================================
            local function footer()
                local lazy_ok, lazy = pcall(require, "lazy")
                if not lazy_ok then
                    return "GeoVim — Code at the speed of thought"
                end
                local stats = lazy.stats()
                local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
                return string.format("⚡ Loaded %d/%d plugins in %.2fms", stats.loaded, stats.count, ms)
            end

            -- LazyVimStarted 时再写 footer，避免 startuptime 还没准备好
            vim.api.nvim_create_autocmd("User", {
                pattern = "LazyVimStarted",
                once = true,
                callback = function()
                    dashboard.section.footer.val = footer()
                    pcall(vim.cmd.AlphaRedraw)
                end,
            })
            -- 兜底：VeryLazy 也触发一次（若 LazyVimStarted 没触发）
            vim.api.nvim_create_autocmd("User", {
                pattern = "VeryLazy",
                once = true,
                callback = function()
                    if not dashboard.section.footer.val or dashboard.section.footer.val == "" then
                        dashboard.section.footer.val = footer()
                        pcall(vim.cmd.AlphaRedraw)
                    end
                end,
            })

            -- ============================================
            -- 高亮组（具体颜色在 theme.lua 中按 Neodarcula 配色定义）
            -- ============================================
            dashboard.section.header.opts.hl = "AlphaHeader"
            dashboard.section.buttons.opts.hl = "AlphaButtons"
            dashboard.section.footer.opts.hl = "AlphaFooter"

            -- ============================================
            -- 布局：padding → header → padding → buttons → padding → footer
            -- ============================================
            dashboard.config.layout = {
                { type = "padding", val = 2 },
                dashboard.section.header,
                { type = "padding", val = 2 },
                dashboard.section.buttons,
                { type = "padding", val = 1 },
                dashboard.section.footer,
            }

            dashboard.config.opts.noautocmd = true

            alpha.setup(dashboard.config)

            -- ============================================
            -- 目录启动时也显示 Alpha（NvChad / LazyVim 风格）
            -- ============================================
            -- 默认 alpha 只在 argc()==0 时展示。当用户 `nvim <dir>` 时，
            -- netrw 会抢先接管 buffer，下面的 autocmd 把 cwd 切到该目录，
            -- 关掉 netrw 列表，再调用 :Alpha 让欢迎页正常出现。
            vim.api.nvim_create_autocmd("VimEnter", {
                group = vim.api.nvim_create_augroup("alpha_on_dir", { clear = true }),
                callback = function()
                    if vim.fn.argc() ~= 1 then
                        return
                    end
                    local target = vim.fn.argv(0)
                    if vim.fn.isdirectory(target) ~= 1 then
                        return
                    end
                    vim.cmd("silent! cd " .. vim.fn.fnameescape(target))
                    vim.schedule(function()
                        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                            if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "netrw" then
                                pcall(vim.api.nvim_buf_delete, buf, { force = true })
                            end
                        end
                        pcall(vim.cmd, "Alpha")
                    end)
                end,
            })
        end,
    },
}

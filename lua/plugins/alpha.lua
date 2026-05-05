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
            -- 上方 Zzz 飘浮符号是 LazyVim 标志性细节，营造"沉睡"氛围。
            -- ============================================
            dashboard.section.header.val = {
                [[                                                  z]],
                [[                                              z z]],
                [[                                          z z z]],
                [[ ██████╗ ███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
                [[██╔════╝ ██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
                [[██║  ███╗█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
                [[██║   ██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
                [[╚██████╔╝███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
                [[ ╚═════╝ ╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
            }

            -- ============================================
            -- 双色按钮辅助函数（LazyVim 精修款）
            -- ============================================
            -- 标准 dashboard.button 把按键字符显示在右侧，色调单一。
            -- 这里把右侧文字换成"提示串"（像 SPC ff），并用更暗的 AlphaShortcut
            -- 高亮组绘制，让左侧 label 与右侧 hint 形成视觉层级。
            local function button(sc, label, hint, action)
                local btn = dashboard.button(sc, label, action)
                btn.opts.shortcut = hint
                btn.opts.hl_shortcut = "AlphaShortcut"
                return btn
            end

            -- ============================================
            -- 快捷按钮（hint 文本对齐到 keymaps.lua 中的实际 leader 绑定）
            -- ============================================
            dashboard.section.buttons.val = {
                button("f", "  Find File", "SPC ff", "<cmd>Telescope find_files<CR>"),
                button("e", "  New File", ":enew", "<cmd>ene <BAR> startinsert<CR>"),
                button("r", "  Recent Files", "SPC fo", "<cmd>Telescope oldfiles<CR>"),
                button("g", "  Find Text", "SPC fw", "<cmd>Telescope live_grep<CR>"),
                button("c", "  Config", ":e $MYVIMRC", "<cmd>edit $MYVIMRC<CR>"),
                button("l", "󰒲  Lazy", ":Lazy", "<cmd>Lazy<CR>"),
                button("m", "  Mason", ":Mason", "<cmd>Mason<CR>"),
                button("q", "  Quit", ":qa", "<cmd>qa<CR>"),
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

            -- LazyVimStarted 事件只在 LazyVim 框架里触发；本配置不是 LazyVim,所以这里
            -- 直接订阅 lazy.nvim 自己的 VeryLazy 事件,在 lazy 加载完所有插件后写入 footer。
            vim.api.nvim_create_autocmd("User", {
                pattern = "VeryLazy",
                once = true,
                callback = function()
                    dashboard.section.footer.val = footer()
                    pcall(vim.cmd.AlphaRedraw)
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

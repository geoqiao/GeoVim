-- ============================================
-- Conform.nvim：代码格式化
-- ============================================
-- conform.nvim 是一个异步格式化引擎。
-- 它的好处是：速度快、支持多种格式化工具、可以按文件类型分配不同的格式化器。

return {
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("conform").setup({
                -- 按文件类型指定使用哪个格式化器
                formatters_by_ft = {
                    -- Lua
                    lua = { "stylua" },

                    -- Python：先整理 imports，再格式化最终结果
                    python = { "ruff_organize_imports", "ruff_format" },

                    -- Web 开发：Prettier 统一处理
                    javascript = { "prettier" },
                    typescript = { "prettier" },
                    javascriptreact = { "prettier" },
                    typescriptreact = { "prettier" },
                    css = { "prettier" },
                    html = { "prettier" },
                    json = { "prettier" },
                    yaml = { "prettier" },
                    markdown = { "prettier" },

                    -- SQL
                    sql = { "sqlfluff" },
                },

                -- Ruff 使用 Conform 内置参数，避免自定义 uv 包装丢失 --force-exclude / --exit-zero 等安全选项。
                formatters = {
                    sqlfluff = {
                        require_cwd = false,
                        -- SQLFluff 在应用部分修复但仍有不可修复违规时返回 1，保留其已生成的修复结果。
                        exit_codes = { 0, 1 },
                        args = function()
                            local cfg = vim.fs.joinpath(vim.fn.stdpath("config"), "sqlfluff-sparksql.cfg")
                            if vim.fn.filereadable(cfg) ~= 1 then
                                vim.notify("[GeoVim] SQLFluff 配置文件未找到: " .. cfg, vim.log.levels.WARN)
                            end
                            return {
                                "fix",
                                "--config",
                                cfg,
                                "-",
                            }
                        end,
                    },
                },

                -- 保存时自动格式化（由 conform 官方机制处理，避免竞争条件）
                format_on_save = function(bufnr)
                    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                        return
                    end
                    return { timeout_ms = 10000, lsp_format = "fallback" }
                end,

                log_level = vim.log.levels.WARN,
            })

            -- 手动开关命令
            vim.api.nvim_create_user_command("FormatDisable", function(args)
                if args.bang then
                    vim.b.disable_autoformat = true
                else
                    vim.g.disable_autoformat = true
                end
            end, { bang = true, desc = "禁用自动格式化" })

            vim.api.nvim_create_user_command("FormatEnable", function()
                vim.b.disable_autoformat = false
                vim.g.disable_autoformat = false
            end, { desc = "启用自动格式化" })
        end,
    },
}

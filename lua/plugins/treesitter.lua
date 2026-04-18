-- ============================================
-- Treesitter：语法高亮、缩进、折叠
-- ============================================
-- Treesitter 会把代码解析成一棵树，从而实现非常精准的高亮和缩进。
-- 相比传统的正则高亮，它更快、更准确。
--
-- 注意：nvim-treesitter v1.0+（main 分支）API 已大幅简化：
-- - 高亮与缩进由 Neovim 0.12+ 原生支持，无需再通过 configs.setup 启用
-- - 本插件仅负责 parser 的安装与管理

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        event = { "BufReadPre", "BufNewFile" },
        -- 让 :TSUpdate 等命令也能触发加载
        cmd = { "TSUpdate", "TSUpdateSync", "TSInstall", "TSUninstall" },
        build = ":TSUpdate",
        config = function()
            -- 可选：自定义 parser 安装目录（保持默认即可）
            require("nvim-treesitter").setup({
                install_dir = vim.fs.joinpath(vim.fn.stdpath("data") --[[@as string]], "site"),
            })

            -- 需要确保安装的 parser 列表
            local ensure_installed = {
                "bash",
                "lua",
                "luadoc",
                "markdown",
                "markdown_inline",
                "vim",
                "vimdoc",
                "yaml",
                "toml",
                -- Python
                "python",
                -- Web
                "html",
                "css",
                "javascript",
                "typescript",
                "tsx",
                "json",
                -- SQL
                "sql",
                -- 其他
                "regex",
                "comment",
            }

            -- 自动安装缺失的 parser（仅检查一次，避免每次启动都执行）
            local installed = require("nvim-treesitter.config").get_installed("parsers")
            local to_install = {}
            for _, lang in ipairs(ensure_installed) do
                if not vim.list_contains(installed, lang) then
                    table.insert(to_install, lang)
                end
            end
            if #to_install > 0 then
                require("nvim-treesitter").install(to_install)
            end
        end,
    },
}

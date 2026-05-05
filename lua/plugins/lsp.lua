-- ============================================
-- LSP (Language Server Protocol) 配置
-- ============================================
-- Neovim 0.12+ 推荐使用原生 API：
--   1. vim.lsp.config(name, opts)  → 定义某个 LSP 服务器的配置
--   2. vim.lsp.enable(name)        → 启用该服务器
--   3. LspAttach 自动命令          → 绑定 buffer 级快捷键和补全
--
-- 这完全替代了旧的 require("lspconfig")[server].setup() 写法。

return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            -- ============================================
            -- 0. 把 blink.cmp 的能力注入所有 LSP server
            -- ============================================
            -- blink 比 Vim 内置 client 多支持 snippet、resolve 等高级特性，
            -- 注入后所有 server 在补全时返回更丰富的 item。
            local ok_blink, blink = pcall(require, "blink.cmp")
            if ok_blink then
                vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })
            end

            -- ============================================
            -- 1. Lua 语言服务器
            -- ============================================
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" }, -- 识别 vim 这个全局变量，不报错
                        },
                        workspace = {
                            library = {
                                vim.fn.expand("$VIMRUNTIME/lua"),
                                vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                                vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
                            },
                            maxPreload = 100000,
                            preloadFileSize = 10000,
                        },
                    },
                },
                root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
            })
            vim.lsp.enable("lua_ls")

            -- ============================================
            -- 2. Python (ty)
            -- ============================================
            -- ty 自动检测项目根目录下的 .venv，无需手动注入 pythonPath。
            vim.lsp.config("ty", {
                root_markers = {
                    "pyproject.toml",
                    "ty.toml",
                    "setup.py",
                    "setup.cfg",
                    "requirements.txt",
                    ".git",
                },
            })
            vim.lsp.enable("ty")

            -- ============================================
            -- 3. TypeScript / JavaScript
            -- ============================================
            vim.lsp.config("ts_ls", {
                root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
            })
            vim.lsp.enable("ts_ls")

            -- ============================================
            -- 5. 配置简单的 LSP 服务器（仅 root_markers 不同）
            -- ============================================
            local simple_lsps = {
                "html",
                "cssls",
                "jsonls",
                "yamlls",
                "marksman",
                "sqlls",
            }
            for _, name in ipairs(simple_lsps) do
                vim.lsp.config(name, { root_markers = { ".git" } })
                vim.lsp.enable(name)
            end

            -- ============================================
            -- 6. ESLint (LSP 模式)
            -- ============================================
            -- on_attach 中的 EslintFixAll 逻辑已迁移到 autocmds.lua 的 LspAttach 中
            vim.lsp.config("eslint", {
                root_markers = {
                    ".eslintrc",
                    ".eslintrc.js",
                    ".eslintrc.json",
                    "eslint.config.js",
                    "package.json",
                    ".git",
                },
            })
            vim.lsp.enable("eslint")
        end,
    },
}

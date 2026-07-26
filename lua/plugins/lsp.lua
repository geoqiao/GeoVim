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
        -- blink.cmp 提供 capabilities;放进 dependencies 是为了保证在第一次 BufReadPre
        -- 触发 LSP 初始化之前 blink.cmp 已 require,以便 vim.lsp.config('*') 注入到位。
        -- mason-lspconfig 只做 ensure_installed,与 lsp.lua 之间没有显式依赖关系,这里不再列入。
        dependencies = { "saghen/blink.cmp" },
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
                -- 保留 nvim-lspconfig 的完整 root_markers（含 StyLua / Luacheck 配置文件）。
            })
            vim.lsp.enable("lua_ls")

            -- ============================================
            -- 2. Python (ty)
            -- ============================================
            -- ty 自动检测项目根目录下的 .venv，无需手动注入 pythonPath。
            -- 注意：ty 0.0.x 为早期版本，存在已知的服务器崩溃问题。
            -- 如果频繁遇到 -32602 错误，建议暂时切换到 basedpyright。
            vim.lsp.config("ty", {
                root_markers = {
                    "pyproject.toml",
                    "ty.toml",
                    "setup.py",
                    "setup.cfg",
                    "requirements.txt",
                    ".git",
                },
                settings = {
                    ty = {
                        diagnosticMode = "openFilesOnly",
                        showSyntaxErrors = true,
                    },
                },
            })
            vim.lsp.enable("ty")

            -- ============================================
            -- 3. TypeScript / JavaScript
            -- ============================================
            -- 使用上游 root_dir，保留 monorepo lockfile 检测和 Deno 排除逻辑。
            vim.lsp.enable("ts_ls")

            -- ============================================
            -- 4. 配置简单的 LSP 服务器（root_markers 按语言适配）
            -- ============================================
            local simple_lsps = {
                { name = "html", root = { "package.json", ".git" } },
                { name = "cssls", root = { "package.json", ".git" } },
                { name = "jsonls", root = { "package.json", ".git" } },
                { name = "yamlls", root = { ".git" } },
                { name = "marksman", root = { ".marksman.toml", ".obsidian", ".git" } },
            }
            for _, ls in ipairs(simple_lsps) do
                vim.lsp.config(ls.name, { root_markers = ls.root })
                vim.lsp.enable(ls.name)
            end

            -- ============================================
            -- 5. SQL 语言服务器（单独配置）
            -- ============================================
            -- sqlls 内置的 sqlint 诊断规则与 SQLFluff 风格冲突，
            -- 禁用其诊断发布，统一由 nvim-lint + sqlfluff 管理。
            -- 保留补全、hover、go-to-definition 等其他 LSP 能力。
            vim.lsp.config("sqlls", {
                root_markers = { ".git" },
                handlers = {
                    ["textDocument/publishDiagnostics"] = function() end,
                },
            })
            vim.lsp.enable("sqlls")

            -- ============================================
            -- 6. ESLint (LSP 模式)
            -- ============================================
            -- LspEslintFixAll on save 逻辑统一放在 autocmds.lua 的 LspAttach 中
            -- 沿用 nvim-lspconfig 的 root_dir：它会检查 ESLint 配置、monorepo lockfile，并排除 Deno 项目。
            vim.lsp.enable("eslint")
        end,
    },
}

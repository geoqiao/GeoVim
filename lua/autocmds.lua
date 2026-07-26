-- ============================================
-- 自动命令 (Autocmds)
-- ============================================
-- 自动命令 = "当发生某件事时，自动执行某个操作"。
-- 比如：保存时自动格式化、打开文件时恢复光标位置、LSP 启动时绑定快捷键。

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ============================================
-- 1. 打开文件时，恢复上一次光标所在的位置
-- ============================================
autocmd("BufReadPost", {
    group = augroup("restore_cursor", { clear = true }),
    callback = function(args)
        local valid_line = vim.fn.line("'\"") >= 1 and vim.fn.line("'\"") <= vim.fn.line("$")
        local not_commit = vim.bo[args.buf].filetype ~= "commit"
        if valid_line and not_commit then
            vim.cmd('normal! g`"')
        end
    end,
})

-- ============================================
-- 2. 高亮复制内容（yank 后的短暂高亮）
-- ============================================
-- 复制后，被复制的内容会闪一下黄色，让你知道操作成功了
autocmd("TextYankPost", {
    group = augroup("highlight_yank", { clear = true }),
    callback = function()
        -- Neovim 0.11+ 推荐 vim.hl.on_yank;参数名是 higroup（不是 group）。
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
})

-- ============================================
-- 3. LSP 启动时自动绑定_buffer级别_的快捷键和功能
-- ============================================
-- 这是 Neovim 0.10+ 推荐的标准做法：不再在 lspconfig 里写 on_attach，
-- 而是统一在 LspAttach 事件里做。
autocmd("LspAttach", {
    group = augroup("lsp_attach", { clear = true }),
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
            return
        end

        -- ----------- 代码导航 -----------
        vim.keymap.set(
            "n",
            "gd",
            vim.lsp.buf.definition,
            { buffer = bufnr, desc = "跳转到定义 (Go to Definition)" }
        )
        vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "查看引用 (References)" })
        vim.keymap.set(
            "n",
            "gi",
            vim.lsp.buf.implementation,
            { buffer = bufnr, desc = "跳转到实现 (Implementation)" }
        )
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "悬浮文档 (Hover)" })
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "跳转到声明 (Declaration)" })

        -- ----------- 代码操作 -----------
        vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { buffer = bufnr, desc = "重命名符号 (Rename)" })
        vim.keymap.set(
            { "n", "v" },
            "<leader>ca",
            vim.lsp.buf.code_action,
            { buffer = bufnr, desc = "代码动作 (Code Action)" }
        )
        vim.keymap.set(
            "n",
            "<leader>ds",
            vim.lsp.buf.document_symbol,
            { buffer = bufnr, desc = "文档符号 (Document Symbols)" }
        )
        vim.keymap.set(
            "n",
            "<leader>ws",
            vim.lsp.buf.workspace_symbol,
            { buffer = bufnr, desc = "工作区符号 (Workspace Symbols)" }
        )

        -- ----------- ESLint Fix All on save（从 lsp.lua 迁移至此，集中管理） -----------
        if client.name == "eslint" then
            autocmd("BufWritePre", {
                group = augroup("eslint_fix_" .. bufnr, { clear = true }),
                buffer = bufnr,
                callback = function()
                    -- 命令由 nvim-lspconfig 的 eslint on_attach 创建；若上游 API 变化则安全跳过，不能阻断保存。
                    if vim.fn.exists(":LspEslintFixAll") == 2 then
                        local ok, err = pcall(vim.cmd.LspEslintFixAll)
                        if not ok then
                            vim.notify("[GeoVim] ESLint 自动修复失败: " .. tostring(err), vim.log.levels.WARN)
                        end
                    end
                end,
            })
        end
    end,
})

-- 4. LSP 断开时清理 buffer-local 自动命令（防止 LspRestart 后重复注册）
autocmd("LspDetach", {
    group = augroup("lsp_detach", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client.name ~= "eslint" then
            return
        end

        -- 只有 ESLint 自身断开时才清理，避免 ts_ls 等其他 client 离开后误删保存修复。
        pcall(vim.api.nvim_clear_autocmds, { buffer = args.buf, group = "eslint_fix_" .. args.buf })
    end,
})

-- ============================================
-- 5. Treesitter 高亮启动
-- ============================================
-- Treesitter 高亮启动逻辑已迁移至 lua/plugins/treesitter.lua 的 config 函数中，
-- 通过 FileType autocmd 统一调用 vim.treesitter.start()。
-- 注意：nvim-treesitter v1.0+ (main 分支) 的 plugin 文件并不会自动启动高亮，
-- 必须由用户显式配置。详见 treesitter.lua 中的实现与注释。

-- ============================================
-- 6. 自动运行 linter
-- ============================================
-- Lua / Python 在离开 Insert 模式或保存后检查；SQLFluff 较重，仅在保存后运行。
autocmd({ "BufWritePost", "InsertLeave" }, {
    group = augroup("auto_lint", { clear = true }),
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if not vim.list_contains({ "lua", "python", "sql" }, ft) then
            return
        end
        if ft == "sql" and args.event == "InsertLeave" then
            return
        end

        local ok, lint = pcall(require, "lint")
        if not ok then
            vim.notify("[GeoVim] nvim-lint 未加载，跳过 lint", vim.log.levels.WARN)
            return
        end
        local success, err = pcall(lint.try_lint)
        if not success then
            vim.notify("[GeoVim] Lint 运行失败: " .. tostring(err), vim.log.levels.WARN)
        end
    end,
})

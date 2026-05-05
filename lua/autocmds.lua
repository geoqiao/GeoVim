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
        -- 兼容 Neovim 0.10 ~ 0.12+ 的高亮 API
        local ok = pcall(vim.hl.on_yank, { group = "IncSearch", timeout = 150 })
        if not ok then
            pcall(vim.highlight.on_yank, { higroup = "IncSearch", timeout = 150 })
        end
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
                command = "EslintFixAll",
            })
        end
    end,
})

-- 4. LSP 断开时清理 buffer-local 自动命令（防止 LspRestart 后重复注册）
autocmd("LspDetach", {
    group = augroup("lsp_detach", { clear = true }),
    callback = function(args)
        -- 清理该 buffer 上由 eslint_fix_<bufnr> 组创建的 BufWritePre 自动命令
        pcall(vim.api.nvim_clear_autocmds, { buffer = args.buf, group = "eslint_fix_" .. args.buf })
    end,
})

-- ============================================
-- 5. 自动启用 Treesitter 语法高亮
-- ============================================
-- nvim-treesitter v1.0+ 不再提供 highlight.enable 选项，
-- Neovim 0.12+ 原生支持 treesitter 高亮，但需要手动调用 vim.treesitter.start() 启动。
-- 这里通过 FileType 事件，为所有有对应 parser 的文件类型自动启用高亮。
autocmd("FileType", {
    group = augroup("treesitter_highlight", { clear = true }),
    callback = function(args)
        -- 避免对已启动的 buffer 重复调用
        if vim.b[args.buf].ts_highlight_enabled then
            return
        end
        local ft = vim.bo[args.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then
            return
        end
        -- 检查 parser 是否已安装（避免报错）
        local ok, _ = pcall(vim.treesitter.language.inspect, lang)
        if ok then
            pcall(vim.treesitter.start, args.buf, lang)
            vim.b[args.buf].ts_highlight_enabled = true
        end
    end,
})

-- ============================================
-- 6. 离开 Insert 模式或保存后自动运行 linter
-- ============================================
autocmd({ "BufWritePost", "InsertLeave" }, {
    group = augroup("auto_lint", { clear = true }),
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if not vim.tbl_contains({ "lua", "python", "sql" }, ft) then
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

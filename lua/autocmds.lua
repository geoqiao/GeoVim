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
        -- Neovim 0.12 已原生提供 gri / grr / K 等 LSP 映射；不再覆盖 gi、gr 的 Vim 语义。
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
-- 5. 按文件类型应用编辑体验
-- ============================================
local two_space_filetypes = {
    "css",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "less",
    "scss",
    "svelte",
    "typescript",
    "typescriptreact",
    "vue",
    "yaml",
}
local markdown_filetypes = { "markdown", "markdown.mdx", "vimwiki" }

local function apply_editor_profile(bufnr, apply_indent)
    local ft = vim.bo[bufnr].filetype
    -- 缩进默认值只在 FileType 阶段设置；随后运行的原生 EditorConfig 仍可覆盖。
    if apply_indent and vim.list_contains(two_space_filetypes, ft) then
        vim.bo[bufnr].shiftwidth = 2
        vim.bo[bufnr].tabstop = 2
        vim.bo[bufnr].softtabstop = 2
        vim.bo[bufnr].expandtab = true
    elseif apply_indent and (ft == "lua" or ft == "python") then
        vim.bo[bufnr].shiftwidth = 4
        vim.bo[bufnr].tabstop = 4
        vim.bo[bufnr].softtabstop = 4
        vim.bo[bufnr].expandtab = true
    end

    local is_markdown = vim.list_contains(markdown_filetypes, ft)
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(winid) == bufnr then
            vim.wo[winid].wrap = is_markdown
            vim.wo[winid].linebreak = is_markdown
            vim.wo[winid].breakindent = is_markdown
            vim.wo[winid].colorcolumn = ""
        end
    end
end

autocmd({ "FileType", "BufWinEnter" }, {
    group = augroup("editor_profiles", { clear = true }),
    callback = function(args)
        apply_editor_profile(args.buf, args.event == "FileType")
    end,
})

-- ============================================
-- 6. 敏感文件（包括 :saveas / :file 改名后）不写入 persistent undo / swap
-- ============================================
local security = require("security")
autocmd({ "BufReadPre", "BufNewFile", "BufFilePost" }, {
    group = augroup("protect_sensitive_files", { clear = true }),
    pattern = security.patterns,
    callback = function(args)
        security.protect_buffer(args.buf)
    end,
})

-- ============================================
-- 7. Treesitter 高亮启动
-- ============================================
-- Treesitter 高亮启动逻辑已迁移至 lua/plugins/treesitter.lua 的 config 函数中，
-- 通过 FileType autocmd 统一调用 vim.treesitter.start()。
-- 注意：nvim-treesitter v1.0+ (main 分支) 的 plugin 文件并不会自动启动高亮，
-- 必须由用户显式配置。详见 treesitter.lua 中的实现与注释。

-- ============================================
-- 8. 保存后运行 linter
-- ============================================
-- LSP 负责实时诊断；Ruff、Luacheck 和 SQLFluff 只在保存后运行，避免频繁启动外部进程。
autocmd("BufWritePost", {
    group = augroup("auto_lint", { clear = true }),
    callback = function(args)
        if not vim.list_contains({ "lua", "python", "sql" }, vim.bo[args.buf].filetype) then
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

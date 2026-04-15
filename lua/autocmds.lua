-- ============================================
-- 自动命令 (Autocmds)
-- ============================================
-- 自动命令 = “当发生某件事时，自动执行某个操作”。
-- 比如：保存时自动格式化、打开文件时恢复光标位置、LSP 启动时绑定快捷键。

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ============================================
-- 1. 打开文件时，恢复上一次光标所在的位置
-- ============================================
autocmd("BufReadPost", {
  group = augroup("restore_cursor", { clear = true }),
  callback = function(args)
    local valid_line = vim.fn.line("'\"") >= 1
      and vim.fn.line("'\"") <= vim.fn.line("$")
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
    if not client then return end

    -- ----------- 代码导航 -----------
    vim.keymap.set("n", "gd", vim.lsp.buf.definition,
      { buffer = bufnr, desc = "跳转到定义 (Go to Definition)" })
    vim.keymap.set("n", "gr", vim.lsp.buf.references,
      { buffer = bufnr, desc = "查看引用 (References)" })
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation,
      { buffer = bufnr, desc = "跳转到实现 (Implementation)" })
    vim.keymap.set("n", "K", vim.lsp.buf.hover,
      { buffer = bufnr, desc = "悬浮文档 (Hover)" })
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration,
      { buffer = bufnr, desc = "跳转到声明 (Declaration)" })

    -- ----------- 代码操作 -----------
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,
      { buffer = bufnr, desc = "重命名符号 (Rename)" })
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action,
      { buffer = bufnr, desc = "代码动作 (Code Action)" })
    vim.keymap.set("n", "<leader>ds", vim.lsp.buf.document_symbol,
      { buffer = bufnr, desc = "文档符号 (Document Symbols)" })
    vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol,
      { buffer = bufnr, desc = "工作区符号 (Workspace Symbols)" })

    -- ----------- 诊断（错误/警告）跳转 -----------
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev({ float = true }) end,
      { buffer = bufnr, desc = "上一个诊断" })
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next({ float = true }) end,
      { buffer = bufnr, desc = "下一个诊断" })
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float,
      { buffer = bufnr, desc = "查看当前诊断详情" })

    -- ----------- 原生代码补全 (Neovim 0.10+) -----------
    -- 当 LSP 连接上后，自动启用基于 LSP 的补全菜单。
    -- 不需要额外的补全插件！
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, {
        autotrigger = true,    -- 输入时自动弹出补全
        convert = function(item)
          -- 让补全项显示更简洁
          return { abbr = item.label:gsub("%b()", "") }
        end,
      })
    end

    -- ----------- 保存时自动格式化 -----------
    -- 如果你的 LSP 支持格式化，保存时也会尝试用 LSP 格式化
    -- （conform.nvim 优先级更高，但如果 conform 没配置，就靠 LSP）
    if client:supports_method("textDocument/formatting") then
      autocmd("BufWritePre", {
        group = augroup("lsp_format_" .. bufnr, { clear = true }),
        buffer = bufnr,
        callback = function()
          -- 只有当 conform.nvim 不存在或没处理时，才用 LSP 格式化
          local ok, conform = pcall(require, "conform")
          if not ok or not conform.will_fallback_to_lsp({ bufnr = bufnr }) then
            vim.lsp.buf.format({ bufnr = bufnr, id = client.id })
          end
        end,
      })
    end

  end,
})

-- ============================================
-- 4. 保存时自动用 conform.nvim 格式化
-- ============================================
-- conform.nvim 优先级最高：python = ruff, web = prettier, sql = sqlfluff
autocmd("BufWritePre", {
  group = augroup("conform_format", { clear = true }),
  callback = function(args)
    local ok, conform = pcall(require, "conform")
    if ok then
      conform.format({ bufnr = args.buf, lsp_fallback = true, async = false })
    end
  end,
})

-- ============================================
-- 5. 离开 Insert 模式或保存后自动运行 linter
-- ============================================
autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = augroup("auto_lint", { clear = true }),
  callback = function()
    local ok, lint = pcall(require, "lint")
    if ok then
      lint.try_lint()
    end
  end,
})

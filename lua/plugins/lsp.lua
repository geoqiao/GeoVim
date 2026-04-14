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
      -- 3. Python (basedpyright) —— 已禁用
      -- ============================================
      -- vim.lsp.config("basedpyright", { ... })
      -- vim.lsp.enable("basedpyright")

      -- ============================================
      -- 4. TypeScript / JavaScript
      -- ============================================
      vim.lsp.config("ts_ls", {
        root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
      })
      vim.lsp.enable("ts_ls")

      -- ============================================
      -- 5. HTML
      -- ============================================
      vim.lsp.config("html", {
        root_markers = { ".git" },
      })
      vim.lsp.enable("html")

      -- ============================================
      -- 6. CSS
      -- ============================================
      vim.lsp.config("cssls", {
        root_markers = { ".git" },
      })
      vim.lsp.enable("cssls")

      -- ============================================
      -- 7. ESLint (LSP 模式)
      -- ============================================
      vim.lsp.config("eslint", {
        root_markers = { ".eslintrc", ".eslintrc.js", ".eslintrc.json", "eslint.config.js", "package.json", ".git" },
        on_attach = function(client, bufnr)
          -- 保存时自动 ESLint Fix All
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      })
      vim.lsp.enable("eslint")

      -- ============================================
      -- 8. SQL
      -- ============================================
      vim.lsp.config("sqlls", {
        root_markers = { ".git" },
      })
      vim.lsp.enable("sqlls")

      -- ============================================
      -- 9. JSON
      -- ============================================
      vim.lsp.config("jsonls", {
        root_markers = { ".git" },
      })
      vim.lsp.enable("jsonls")

      -- ============================================
      -- 10. YAML
      -- ============================================
      vim.lsp.config("yamlls", {
        root_markers = { ".git" },
      })
      vim.lsp.enable("yamlls")

      -- ============================================
      -- 11. Markdown (Marksman)
      -- ============================================
      vim.lsp.config("marksman", {
        root_markers = { ".git" },
      })
      vim.lsp.enable("marksman")

      -- ============================================
      -- 诊断显示的样式优化
      -- ============================================
      vim.diagnostic.config({
        virtual_text = true,            -- 在行尾显示简短错误信息
        signs = true,                   -- 左侧显示错误/警告图标
        underline = true,               -- 给有问题的代码加下划线
        update_in_insert = false,       -- Insert 模式下不更新诊断，减少干扰
        severity_sort = true,           -- 按严重程度排序
        float = {
          border = "rounded",
          source = true,
        },
      })
    end,
  },
}

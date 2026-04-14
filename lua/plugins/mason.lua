-- ============================================
-- Mason：一键安装 LSP / Formatter / Linter
-- ============================================
-- Mason 就像一个“应用商店”，你只需要运行 :Mason，
-- 就可以用图形界面安装 ty、ruff、prettier 等所有工具。
-- 本配置会把常用工具设为“自动确保已安装”。

return {
  -- Mason 本体和 UI
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },

  -- Mason 与 lspconfig 的桥梁：自动安装 LSP
  {
    "williamboman/mason-lspconfig.nvim",
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        -- 自动确保安装的 LSP 服务器列表
        ensure_installed = {
          "lua_ls",           -- Lua
          "ty",               -- Python 类型检查（默认启用）
          "ts_ls",            -- TypeScript / JavaScript
          "html",             -- HTML
          "cssls",            -- CSS
          "eslint",           -- ESLint (LSP 模式)
          "sqlls",            -- SQL
          "jsonls",           -- JSON
          "yamlls",           -- YAML
          "marksman",         -- Markdown
        },
        automatic_installation = false,
        handlers = {
          -- 禁用 basedpyright / pyright，避免与 ty 冲突
          ["basedpyright"] = function() end,
          ["pyright"] = function() end,
          -- 其它 LSP 走默认 setup
          function(server_name)
            require("lspconfig")[server_name].setup({})
          end,
        },
      })
    end,
  },

  -- Mason 与格式化/检查工具的桥梁：自动安装非 LSP 工具
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- Lua
          "stylua",
          -- Python
          "ruff",
          -- Web
          "prettier",
          -- SQL
          "sqlfluff",
        },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },
}

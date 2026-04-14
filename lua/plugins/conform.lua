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
      -- 检测当前项目是否使用 uv 作为包管理器
      local use_uv = vim.fn.executable("uv") == 1

      require("conform").setup({
        -- 按文件类型指定使用哪个格式化器
        formatters_by_ft = {
          -- Lua
          lua = { "stylua" },

          -- Python：ruff 负责格式化 + 自动整理 imports
          python = { "ruff_format", "ruff_organize_imports" },

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

        -- 自定义格式化器的命令和参数
        formatters = {
          ruff_format = {
            command = use_uv and "uv" or "ruff",
            args = use_uv
                and { "run", "ruff", "format", "--stdin-filename", "$FILENAME", "-" }
                or nil,
          },
          ruff_organize_imports = {
            command = use_uv and "uv" or "ruff",
            args = use_uv
                and { "run", "ruff", "check", "--select", "I", "--fix", "--stdin-filename", "$FILENAME", "-" }
                or nil,
          },
          sqlfluff = {
            args = {
              "fix",
              "--dialect=ansi",
              "-",
            },
          },
        },

        -- 保存时自动格式化（已在 autocmds.lua 中统一触发，这里只留配置）
        format_on_save = nil,
      })
    end,
  },
}

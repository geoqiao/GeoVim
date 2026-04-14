-- ============================================
-- Treesitter：语法高亮、缩进、折叠
-- ============================================
-- Treesitter 会把代码解析成一棵树，从而实现非常精准的高亮和缩进。
-- 相比传统的正则高亮，它更快、更准确。
--
-- 注意：nvim-treesitter 1.0+ 已移除旧的 nvim-treesitter.configs 模块，
-- 直接使用 require("nvim-treesitter").setup({}) 即可。

return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    -- 让 :TSUpdate 等命令也能触发加载
    cmd = { "TSUpdate", "TSUpdateSync", "TSInstall", "TSUninstall" },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        -- 确保安装的语言解析器列表
        ensure_installed = {
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
        },

        -- 启用语法高亮
        highlight = {
          enable = true,
        },

        -- 启用基于 Treesitter 的缩进
        indent = { enable = true },

        -- 进入新缓冲区时，自动安装缺失的解析器
        auto_install = true,
      })
    end,
  },
}

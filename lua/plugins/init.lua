-- ============================================
-- 插件主列表
-- ============================================
-- lazy.nvim 会自动读取 lua/plugins/ 下的所有 .lua 文件。
-- 每个文件 return 一个或一组插件配置表。
-- 为了让结构更清晰，我把每个插件或相关插件组拆成了单独的文件。

return {
  -- 先加载主题，确保界面一开始就好看
  { import = "plugins.theme" },

  -- 文件树、搜索、状态栏等 UI 插件
  { import = "plugins.nvimtree" },
  { import = "plugins.telescope" },
  { import = "plugins.lualine" },
  { import = "plugins.bufferline" },
  { import = "plugins.whichkey" },

  -- 语法高亮
  { import = "plugins.treesitter" },

  -- LSP、格式化、代码检查
  { import = "plugins.mason" },
  { import = "plugins.lsp" },
  { import = "plugins.conform" },
  { import = "plugins.lint" },

  -- Git 增强
  { import = "plugins.gitsigns" },

  -- Markdown 支持
  { import = "plugins.markdown" },

  -- 快速注释（VSCode 式 Ctrl+/）
  { import = "plugins.comment" },

  -- Claude Code 集成
  { import = "plugins.claude-code" },
}

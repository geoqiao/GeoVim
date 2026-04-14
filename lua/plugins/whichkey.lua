-- ============================================
-- Which-Key：快捷键提示助手
-- ============================================
-- 当你按了 <leader>（空格键）或其他前缀键后，屏幕下方会弹出一个提示面板，
-- 告诉你接下来可以按什么键。对新手极其友好！

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        preset = "modern",
        delay = 300, -- 按键后 300ms 再弹出提示，反应更快
        icons = {
          mappings = false, -- 不使用图标，纯文字对新手更直观
        },
      })

      -- 注册常用的前缀分组，让提示更有条理
      require("which-key").add({
        { "<leader>f", group = "Find / Search" },
        { "<leader>e", group = "Explorer" },
        { "<leader>s", group = "Split" },
        { "<leader>g", group = "Git" },
        { "<leader>m", group = "Markdown" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>c", group = "Code Action" },
        { "<leader>y", group = "System Clipboard" },
      })
    end,
  },
}

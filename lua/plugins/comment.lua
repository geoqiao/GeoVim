-- ============================================
-- Comment.nvim：快速注释代码
-- ============================================
-- 支持 gcc（单行注释）、gc（选中注释）、gb（块注释）等。
-- keymaps.lua 中额外绑定了 gcc / gc 作为备用入口。

return {
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      toggler = {
        line = "gcc",
        block = "gbc",
      },
      opleader = {
        line = "gc",
        block = "gb",
      },
    },
  },
}

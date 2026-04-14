-- ============================================
-- Gitsigns：Git 增强
-- ============================================
-- 在左侧行号边显示代码修改标记（增加/删除/修改），
-- 并支持 blame、预览 hunk、撤销 hunk 等操作。

return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        current_line_blame = false, -- 默认不显示当前行 blame，减少视觉干扰
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 1000,
        },
        on_attach = function(bufnr)
          -- 可以在这里绑定更多 Git 相关的 buffer 级快捷键
          local gs = package.loaded.gitsigns
          vim.keymap.set("n", "<leader>gb", function() gs.blame_line({ full = true }) end,
            { buffer = bufnr, desc = "Git Blame 当前行" })
          vim.keymap.set("n", "<leader>gp", gs.preview_hunk,
            { buffer = bufnr, desc = "预览当前 Hunk" })
          vim.keymap.set("n", "<leader>gr", gs.reset_hunk,
            { buffer = bufnr, desc = "撤销当前 Hunk" })
          vim.keymap.set("n", "]g", gs.next_hunk,
            { buffer = bufnr, desc = "下一个 Hunk" })
          vim.keymap.set("n", "[g", gs.prev_hunk,
            { buffer = bufnr, desc = "上一个 Hunk" })
        end,
      })
    end,
  },
}

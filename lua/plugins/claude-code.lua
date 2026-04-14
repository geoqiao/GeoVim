-- ============================================
-- Claude Code：在 Neovim 中集成 Claude Code CLI
-- ============================================
-- 按 <leader>cc 在当前项目底部打开 Claude Code 终端面板，
-- 按 <leader>cC 继续上次对话，<leader>cR 选择历史对话。
-- Claude Code 修改的文件会自动刷新到 Neovim 缓冲区中。

return {
  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume", "ClaudeCodeVerbose" },
    keys = {
      { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "打开/关闭 Claude Code", mode = "n" },
      { "<leader>cC", "<cmd>ClaudeCodeContinue<cr>", desc = "Claude Code 继续对话", mode = "n" },
      { "<leader>cR", "<cmd>ClaudeCodeResume<cr>", desc = "Claude Code 恢复对话", mode = "n" },
      { "<leader>cV", "<cmd>ClaudeCodeVerbose<cr>", desc = "Claude Code 详细模式", mode = "n" },
    },
    config = function()
      require("claude-code").setup({
        -- 命令路径（claude 命令必须已在 PATH 中）
        command = "claude",

        -- 终端窗口设置
        window = {
          split_ratio = 0.5,       -- 占用 50% 的屏幕宽度
          position = "vertical",   -- 左侧垂直分屏打开
          enter_insert = true,     -- 打开后自动进入插入模式
          hide_numbers = true,     -- 隐藏行号
          hide_signcolumn = true,  -- 隐藏 signcolumn
        },

        -- 文件自动刷新：Claude Code 修改文件后，Neovim 自动重载
        refresh = {
          enable = true,
          updatetime = 100,
          timer_interval = 1000,
          show_notifications = true,
        },

        -- Git 项目设置
        git = {
          use_git_root = true, -- 在 git 项目里自动把 CWD 切到项目根目录
        },

        -- 扩展命令参数
        command_variants = {
          continue = "--continue",
          resume = "--resume",
          verbose = "--verbose",
        },

        -- 键位映射
        keymaps = {
          toggle = {
            normal = "<leader>cc",
            terminal = "<leader>cc",
            variants = {
              continue = "<leader>cC",
              verbose = "<leader>cV",
            },
          },
          window_navigation = true, -- 在 Claude Code 终端里可用 <C-h/j/k/l> 切窗口
          scrolling = true,         -- 在 Claude Code 终端里可用 <C-f/b> 翻页
        },
      })
    end,
  },
}

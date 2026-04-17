-- ============================================
-- Markdown 支持
-- ============================================
-- 1. markdown-preview.nvim：在浏览器中实时预览 Markdown
--
-- 注：render-markdown.nvim（编辑器内渲染）目前与 Neovim 0.12 + Treesitter
-- 最新版存在兼容性崩溃，为了保证配置对新手绝对稳定，我们暂时只保留
-- 浏览器预览。如果你以后想尝试编辑器内渲染，可以取消下面注释并执行
-- :Lazy update

return {
    -- 浏览器实时预览
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "浏览器 Markdown 预览" },
        },
        build = "cd app && npm install",
        config = function()
            -- 使用系统 Node 直接运行，避免 build 步骤下载预编译二进制失败的问题
            vim.g.mkdp_node_path = vim.fn.exepath("node")
            vim.g.mkdp_auto_start = 0 -- 打开 md 文件时不自动启动浏览器
            vim.g.mkdp_auto_close = 1 -- 切换 buffer 时自动关闭预览
            vim.g.mkdp_refresh_slow = 0 -- 实时刷新（不是等到保存后才刷新）
            vim.g.mkdp_page_title = "${name}.md"
        end,
    },

    -- 编辑器内渲染效果（暂时禁用，等待上游修复兼容性问题）
    -- {
    --   "MeanderingProgrammer/render-markdown.nvim",
    --   version = "v8.10.0",
    --   ft = { "markdown" },
    --   dependencies = { "nvim-treesitter/nvim-treesitter" },
    --   config = function()
    --     require("render-markdown").setup({})
    --   end,
    -- },
}

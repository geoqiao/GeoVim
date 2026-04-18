-- ============================================
-- nvim-lint：代码检查 (Linting)
-- ============================================
-- nvim-lint 会在后台运行代码检查工具（如 ruff、eslint、sqlfluff），
-- 并将结果显示在左侧诊断栏。它与 LSP 诊断是互补关系。
--
-- 注意：JS/TS 的 lint 已经完全交给 ESLint LSP 处理，
-- 这里不再用 nvim-lint 运行 eslint，避免双重报错。

return {
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")

            -- 按文件类型分配 linter
            lint.linters_by_ft = {
                lua = { "luacheck" },
                python = { "ruff" },
                sql = { "sqlfluff" },
            }

            -- 让 luacheck 知道 Neovim 和 Love2D 的全局变量，避免误报
            lint.linters.luacheck.args = vim.iter({
                lint.linters.luacheck.args or {},
                { "--globals", "vim", "love" },
            }):flatten():totable()
        end,
    },
}

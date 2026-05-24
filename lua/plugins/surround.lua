-- ============================================
-- Surround：快速操作成对符号
-- ============================================
-- 与 mini.pairs 形成完整工具链：pairs 负责"插入时自动配对"，
-- surround 负责"修改/删除/添加"已有配对。
--
-- 示例操作：
--   saiw)  → 在单词周围添加括号 (surround add inner word )
--   sd'    → 删除周围的单引号 (surround delete ')
--   sr')"  → 把单引号替换为双引号 (surround replace ' with ")
--   sf'    → 查找并包围到下一个单引号 (surround find ')

return {
    {
        "echasnovski/mini.surround",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            -- 环绕操作的前缀键（默认 g）
            -- 与原生 gs（睡眠）不冲突，因为 gs 很少用
            mappings = {
                add = "sa", -- 添加环绕
                delete = "sd", -- 删除环绕
                find = "sf", -- 查找环绕（右）
                find_left = "sF", -- 查找环绕（左）
                highlight = "sh", -- 高亮环绕
                replace = "sr", -- 替换环绕
                update_n_lines = "sn", -- 更新查找行数
            },
            -- 搜索环绕的配对符号时，从光标位置开始向外查找
            search_method = "cover",
            -- 识别配对的自定义逻辑（与 treesitter 配合更智能）
            custom_surroundings = nil,
            -- 静默执行（不显示操作提示）
            silent = false,
            -- 在 visual 模式下也生效
            n_lines = 20, -- 查找环绕时最多搜索多少行
        },
        config = function(_, opts)
            require("mini.surround").setup(opts)
        end,
    },
}

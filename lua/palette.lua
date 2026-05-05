-- ============================================
-- GeoVim Aurora 调色板（单一来源）
-- ============================================
-- 把 lualine、noice、alpha、theme 共享的颜色集中到这里，避免散落多处。
-- 保留 Neodarcula 的橙黄品牌主调（#CC7832 / #FFC66D），
-- 同时为状态栏 6 种模式与诊断信息引入语义化配色。

return {
    -- 背景层级（深 → 浅）：page < base < panel < elevated < hover
    bg = {
        page = "#1A1B1E", -- 终端背景兜底
        base = "#2B2B2B", -- Neodarcula 默认 Normal 背景
        panel = "#313335", -- 状态栏 / 普通浮窗的“面板”
        elevated = "#3C3F41", -- 命令行 / 补全菜单的“抬升”面板
        hover = "#4B4D4F", -- 悬浮 / 选中条
    },

    -- 前景层级（深 → 浅）：subtle < muted < secondary < primary
    fg = {
        primary = "#BBBBBB", -- 主要正文
        secondary = "#9E9E9E", -- 次要信息（路径、文件类型）
        muted = "#6F7177", -- 弱提示（分隔线 label、footer）
        subtle = "#4F525A", -- 极弱（divider 线条本体）
    },

    -- 品牌主色（沿用 Neodarcula 的关键字 / 函数色）
    brand = {
        orange = "#CC7832", -- 关键字色，命令行边框、Logo 主体
        yellow = "#FFC66D", -- 函数色，按钮 label
    },

    -- Vim 模式语义色
    mode = {
        normal = "#6897BB", -- 钢蓝：Darcula 数字色
        insert = "#A8C66C", -- 鼠尾草绿：清爽“可输入”
        visual = "#C792EA", -- 兰花紫：明显的“选中”
        replace = "#E06C75", -- 柔红：警示
        command = "#CC7832", -- 品牌橙：执行命令
        terminal = "#4FC3A1", -- 青绿：终端独立色域
    },

    -- 诊断信息
    diag = {
        error = "#E06C75",
        warn = "#FFC66D",
        info = "#6897BB",
        hint = "#4FC3A1",
    },
}

# AGENTS.md

> 本文档供 AI 编码助手阅读。如果你对人类用户可见的说明感兴趣，请参阅 `README.md`、`Neovim-guide.md` 和 `MAINTENANCE.md`。

---

## 项目概览

这是一个**个人 Neovim 配置文件**，完全使用 Lua 编写，目标 Neovim 版本 >= **0.12**。配置从零独立编写，**不依赖 NvChad** 等模板。所有配置文件均带有详细的中文注释，整体风格追求简洁、现代、对新手友好，同时保留纯粹的 Vim 操作习惯。

**仓库路径**：`~/.config/nvim`  
**核心语言**：Lua  
**包管理器**：[lazy.nvim](https://github.com/folke/lazy.nvim)  
**LSP 方案**：Neovim 0.12+ 原生 API（`vim.lsp.config` / `vim.lsp.enable`）  
**代码补全**：原生 `vim.lsp.completion.enable()`（**未安装 nvim-cmp**）

---

## 目录结构与代码组织

```
~/.config/nvim/
├── init.lua              -- 启动入口：安装 lazy.nvim、加载核心模块、加载插件
├── lazy-lock.json        -- lazy.nvim 插件版本锁定文件
├── .stylua.toml          -- Lua 代码格式化配置
├── lua/
│   ├── options.lua       -- 编辑器基础选项（行号、缩进、主题、剪贴板等）
│   ├── autocmds.lua      -- 自动命令（光标恢复、yank 高亮、LSP Attach、保存格式化等）
│   ├── keymaps.lua       -- 全局快捷键映射
│   └── plugins/          -- 插件配置目录
│       ├── init.lua      -- 插件总列表，仅包含 import 声明
│       ├── theme.lua     -- 主题（Catppuccin frappe）
│       ├── telescope.lua -- 模糊搜索
│       ├── nvimtree.lua  -- 文件树
│       ├── lualine.lua   -- 底部状态栏
│       ├── bufferline.lua-- 顶部 Buffer 标签
│       ├── treesitter.lua-- 语法高亮
│       ├── mason.lua     -- LSP/格式化器/Linter 自动安装
│       ├── lsp.lua       -- LSP 服务器配置（原生 API）
│       ├── conform.lua   -- 代码格式化
│       ├── lint.lua      -- 代码检查
│       ├── gitsigns.lua  -- Git 增强
│       ├── markdown.lua  -- Markdown 浏览器预览
│       ├── comment.lua   -- 快速注释
│       ├── dashboard.lua -- 启动页
│       ├── whichkey.lua  -- 快捷键提示
│       └── claude-code.lua -- Claude Code 集成
└── README.md / CLAUDE.md / MAINTENANCE.md / Neovim-guide.md
```

**加载顺序**：
1. `init.lua` 先确保 `lazy.nvim` 已安装；
2. 按顺序 `require("options")` → `require("autocmds")` → `require("keymaps")`；
3. 最后调用 `require("lazy").setup({ spec = { import = "plugins" } })`，lazy.nvim 会自动导入 `lua/plugins/` 下的所有 `.lua` 文件。

**插件组织约定**：
- `lua/plugins/init.lua` 返回 import 列表，按优先级组织插件加载顺序，不写具体插件配置；
- 每个插件或相关插件组拆分为独立文件，返回 lazy.nvim spec 表；
- 全局键位统一放在 `lua/keymaps.lua`；Buffer 级键位（LSP、Git 等）放在 `lua/autocmds.lua` 或对应插件的 `on_attach` 回调中。

---

## 构建与常用命令

本项目没有传统意义上的“构建”或“测试套件”。开发/维护时常用以下命令：

| 命令 | 作用 |
|------|------|
| `stylua .` | 格式化本仓库所有 Lua 文件 |
| `stylua --check .` | 仅检查格式，不写入 |
| `:Lazy` | 打开 lazy.nvim 插件管理器 |
| `:Lazy update` | 更新所有插件 |
| `:Mason` | 打开 Mason 工具安装器（LSP / Formatter / Linter）|
| `:checkhealth` | 运行 Neovim 健康检查 |
| `:source %` | 重载当前正在编辑的配置文件 |
| `:LspInfo` | 查看当前 Buffer 已连接的 LSP 客户端 |
| `:ConformInfo` | 查看 conform.nvim 的格式化状态 |

---

## 代码风格规范

Lua 代码统一使用 **StyLua** 格式化，配置见 `.stylua.toml`：

- **缩进**：4 个空格（`indent_width = 4`）
- **列宽**：120 列（`column_width = 120`）
- **换行**：Unix 风格（`line_endings = "Unix"`）
- **引号**：自动优先双引号（`quote_style = "AutoPreferDouble"`）

**注释风格**：
- 使用 `--` 单行注释；
- 重要模块顶部使用 `-- ==========` 风格的分隔线；
- 所有配置项尽量附带中文说明，解释“这是什么”以及“为什么这样设”。

**键位设计原则**：
- **Leader 键**：`<Space>`（空格）
- **不覆盖 Vim 核心原生键位**：`hjkl`、`y`/`p`、`Ctrl-o`/`Ctrl-i`、`gg`/`G`、`u`/`Ctrl+r` 等均保持原样；
- **`<Tab>` 故意不映射**，因为它在 Vim 底层等价于 `Ctrl-i`，重映射会破坏跳转列表；
- Buffer 切换使用 `<leader>bn` / `<leader>bp`（保留 `H`/`L` 的原生屏幕导航功能）。

**Git 提交规范**：
- **所有 commit message 必须使用英文**（包括标题和正文），遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范；
- 类型前缀使用小写：`feat:`、`fix:`、`chore:`、`docs:`、`refactor:`、`style:`、`test:`；
- 标题使用祈使语气（如 `fix: resolve ty completion trigger` 而非 `fixed: resolved...`）；
- 如需要详细说明，在标题后空一行写正文，正文同样使用英文。

---

## 测试说明

本项目**没有自动化测试**。验证修改是否正确的常用方式：

1. **格式检查**：`stylua --check .`
2. **语法检查**：在 Neovim 中打开修改后的 Lua 文件，运行 `:luafile %`，观察是否有报错；
3. **功能验证**：
   - 修改 LSP 配置后，打开对应语言文件，运行 `:LspInfo` 确认服务器已连接；
   - 修改格式化配置后，保存对应文件，运行 `:ConformInfo` 确认格式化器被调用；
   - 修改插件配置后，运行 `:Lazy` 查看插件加载状态。

---

## 安全与注意事项

- **Neovim 版本要求 >= 0.12**：配置大量使用了 `vim.lsp.config` / `vim.lsp.enable` 等新 API，低版本无法正常工作；
- **conform.nvim 使用内置的 `format_on_save` 机制**处理保存时格式化，并自动 fallback 到 LSP 格式化。可通过 `:FormatDisable` / `:FormatEnable` 手动开关；
- **Mason 不会自动安装**：`mason-tool-installer.nvim` 设置了 `run_on_start = false`（避免启动阻塞），首次使用需手动运行 `:MasonInstallAll`，之后不会自动更新（`auto_update = false`）；
- **Claude Code 集成**：`greggh/claude-code.nvim` 插件会调用系统 PATH 中的 `claude` 命令，并在左侧打开垂直终端分屏。该插件配置了文件自动刷新（`refresh.enable = true`），Claude Code 修改的文件会自动重载到 Neovim 缓冲区中；
- **剪贴板**：`options.lua` 中设置了 `clipboard = "unnamedplus"`，`y`/`p` 默认与系统剪贴板打通。

---

## 架构要点

### LSP 架构（Neovim 0.12+ 原生 API）

- 服务器定义：`vim.lsp.config(name, opts)`（见 `lua/plugins/lsp.lua`）；
- 服务器启用：`vim.lsp.enable(name)`；
- Buffer 级行为（键位、原生补全）统一在 `lua/autocmds.lua` 的 `LspAttach` 自动命令中处理；
- `nvim-lspconfig` 仅作为 `mason-lspconfig.nvim` 的依赖和 fallback 存在，**不再使用传统的 `lspconfig[server].setup({})` 写法**。

### 格式化与 Lint 管线

- **Formatter**：`conform.nvim`（`lua/plugins/conform.lua`）
  - Lua → `stylua`
  - Python → `ruff_format` + `ruff_organize_imports`（自动检测 `uv` 并适配命令）
  - Web / JSON / YAML / Markdown → `prettier`
  - SQL → `sqlfluff`
- **Linter**：`nvim-lint`（`lua/plugins/lint.lua`）
  - Lua → `luacheck`（传入 `--globals vim love`）
  - Python → `ruff`
  - SQL → `sqlfluff`
- **触发时机**：
  - 保存时自动格式化由 conform.nvim 的 `format_on_save` 统一处理（`lua/plugins/conform.lua`），支持 LSP fallback；
  - Lint 在 `BufWritePost`、`InsertLeave` 时自动触发（`lua/autocmds.lua`）。

### 插件加载策略

- 主题（`catppuccin`）和启动页（`dashboard-nvim`）设置 `lazy = false` 并赋予高 `priority`，确保在 UI 渲染前加载；
- 大部分 UI 插件使用 `event = "VeryLazy"` 延迟加载；
- Treesitter、LSP、格式化、Lint 等使用 `BufReadPre` / `BufNewFile` 事件触发；
- `init.lua` 的 `performance.rtp.disabled_plugins` 中禁用了大量内置冗余插件（如 `netrw`、`tutor`、`gzip` 等），以提升启动速度。

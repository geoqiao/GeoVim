# GeoVim — 现代 Neovim 配置

一套从零独立编写的现代 Neovim 配置，目标简洁、对新手友好，同时**尊重纯粹的 Vim 原生操作习惯**。

> **要求：** Neovim >= 0.12（使用原生 LSP 新 API）

---

## 特性

- **Neovim 0.12+ 原生 LSP**：使用 `vim.lsp.config` / `vim.lsp.enable`
- **原生代码补全**：不安装 nvim-cmp，直接启用 `vim.lsp.completion`
- **懒加载**：基于 [lazy.nvim](https://github.com/folke/lazy.nvim)，启动迅速
- **纯粹 Vim 原生键位**：不覆盖 `hjkl`、`y`/`p`、`Ctrl-o`/`Ctrl-i`、`;`（f/t 重复）、`H`/`L`（屏幕导航）等核心操作
- **中文注释**：所有配置文件都带有详细中文注释

---

## 目录结构

```
~/.config/nvim/
├── init.lua                 -- 启动入口
├── lua/
│   ├── options.lua          -- 编辑器基础选项
│   ├── autocmds.lua         -- 自动命令（LSP Attach、保存格式化、自动 Lint 等）
│   ├── keymaps.lua          -- 全局快捷键
│   └── plugins/             -- 插件配置
│       ├── init.lua         -- 插件总列表（仅 import）
│       ├── theme.lua        -- 主题
│       ├── telescope.lua    -- 模糊搜索
│       ├── nvimtree.lua     -- 文件树
│       ├── lualine.lua      -- 状态栏
│       ├── bufferline.lua   -- Buffer 标签
│       ├── treesitter.lua   -- 语法高亮
│       ├── mason.lua        -- 自动安装 LSP / 格式化器 / Linter
│       ├── lsp.lua          -- LSP 服务器配置
│       ├── conform.lua      -- 代码格式化
│       ├── lint.lua         -- 代码检查
│       ├── gitsigns.lua     -- Git 增强
│       ├── markdown.lua     -- Markdown 预览
│       ├── claude-code.lua  -- Claude Code 集成
│       └── ...
├── .stylua.toml             -- Lua 格式化配置
├── CLAUDE.md                -- Claude Code 操作指南
├── MAINTENANCE.md           -- 维护文档
└── Neovim-guide.md          -- 新手使用指南
```

---

## 环境要求

- **Neovim >= 0.12**
- **Git**（lazy.nvim 插件管理器需要）
- **Node.js + npm**（markdown-preview.nvim 需要）
- **make**（telescope-fzf-native.nvim 编译需要，macOS/Linux 通常已预装）
- **claude** CLI（可选，Claude Code 集成需要）

## 首次启动

1. 确保满足上面的环境要求
2. 首次打开 Neovim 时，`lazy.nvim` 会自动下载所有插件
3. 下载完成后**重启 Neovim**
4. 运行 `:MasonInstallAll` 安装所有开发工具（格式化器、Linter、LSP）
5. 运行 `:checkhealth` 确认一切正常

> 由于 `mason-tool-installer` 不会在启动时自动安装（避免网络阻塞），首次使用必须手动执行 `:MasonInstallAll`。

---

## 常用命令

| 命令 | 作用 |
|------|------|
| `:Lazy` | 打开插件管理器 |
| `:Mason` | 打开 LSP / 格式化器 / Linter 安装器 |
| `:MasonInstallAll` | 一键安装本配置所需的所有 Mason 工具 |
| `:checkhealth` | 健康检查 |
| `:FormatDisable` | 禁用当前 buffer 的自动格式化（加 `!` 全局禁用） |
| `:FormatEnable` | 重新启用自动格式化 |
| `:Telescope find_files` | 查找文件 |
| `:MarkdownPreviewToggle` | 浏览器预览 Markdown |
| `:ClaudeCode` | 打开 Claude Code 面板 |

---

## 快捷键速查

- **Leader**：`<Space>`
- **文件搜索**：`<leader>ff`（文件）、`<leader>fw`（全局搜索）
- **文件树**：`<leader>ee`（开关）、`<leader>eo`（聚焦）
- **Buffer 切换**：`<leader>bn`（下一个）、`<leader>bp`（上一个）
- **关闭 Buffer**：`<leader>bd`（当前）、`<leader>bD`（其他）
- **窗口切换**：`<C-h>` `<C-j>` `<C-k>` `<C-l>`
- **LSP**：`gd`（定义）、`gr`（引用）、`K`（悬浮文档）、`<leader>ca`（代码动作）
- **重命名**：`<leader>cr`
- **格式化**：`<leader>cf`
- **注释**：`gcc`（当前行）、`gc`（选中）
- **诊断**：`[d` / `]d`（跳转）、`<leader>d`（详情）
- **AI**：`<leader>ac`（Claude Code）
- **Git**：`[g` / `]g`（切换 hunk）

完整键位说明见 `lua/keymaps.lua` 和 `Neovim-guide.md`。

---

## 相关文档

- [Neovim-guide.md](./Neovim-guide.md) — 新手入门与快捷键教程
- [MAINTENANCE.md](./MAINTENANCE.md) — 如何维护、添加插件、添加 LSP 等
- [CLAUDE.md](./CLAUDE.md) — 供 Claude Code 使用的仓库上下文

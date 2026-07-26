# GeoVim — 现代 Neovim 配置

一套从零编写的 Neovim 配置，目标是简洁、对新手友好，同时尊重 Vim 原生操作习惯。

> **要求：** Neovim >= 0.12

## 特性

- **原生 LSP 架构**：使用 `vim.lsp.config` / `vim.lsp.enable`
- **现代补全**：使用 [blink.cmp](https://github.com/saghen/blink.cmp)，并向所有 LSP 注入 capabilities
- **格式化与检查**：Conform + nvim-lint，覆盖 Lua、Python、Web 和 Spark SQL
- **按需加载**：lazy.nvim 根据 event、command、key、filetype 或文件 pattern 加载插件
- **数据安全**：保留 swapfile、writebackup，并阻止误关未保存的 Buffer
- **原生键位优先**：保留 `hjkl`、`Ctrl-o`/`Ctrl-i`、`H`/`L`、`y`/`p` 等核心行为
- **AI 集成**：支持 Claude Code 与 pi coding agent
- **中文注释**：配置项说明以中文为主

## 目录结构

```text
~/.config/nvim/
├── init.lua                 -- 启动入口与 lazy.nvim 配置
├── lazy-lock.json           -- 插件版本锁定
├── sqlfluff-sparksql.cfg    -- Spark SQLFluff 配置
├── lua/
│   ├── options.lua          -- 编辑器选项与数据安全设置
│   ├── autocmds.lua         -- LSP Attach、ESLint、Treesitter、自动 Lint
│   ├── keymaps.lua          -- 全局快捷键
│   ├── palette.lua          -- Aurora UI 调色板
│   └── plugins/             -- lazy.nvim 自动扫描，无 init.lua
│       ├── theme.lua / alpha.lua / noice.lua
│       ├── telescope.lua / nvimtree.lua / trouble.lua
│       ├── lsp.lua / cmp.lua / mason.lua
│       ├── conform.lua / lint.lua / treesitter.lua
│       ├── autopairs.lua / surround.lua / todo-comments.lua
│       ├── markdown.lua / image.lua
│       └── claude-code.lua / pi-nvim.lua
├── AGENTS.md / CLAUDE.md    -- AI 编码助手上下文
├── MAINTENANCE.md           -- 维护指南
└── Neovim-guide.md          -- 新手使用指南
```

## 环境要求

必需：

- Neovim >= 0.12
- Git
- Node.js + npm（markdown-preview.nvim）
- `make`（编译 telescope-fzf-native.nvim）
- `ripgrep`（Telescope 全局文本搜索）

按功能可选：

- Nerd Font（图标）
- ImageMagick，且需支持 Sixel（image.nvim）
- 支持 Sixel 的终端；当前配置针对 Ghostty
- `claude` CLI（Claude Code）
- `pi` CLI，并在 pi 侧安装 `pi-nvim` extension
- Homebrew `luacheck`（Lua lint）

## 首次启动

1. 启动 Neovim，等待 lazy.nvim 安装插件。
2. 重启 Neovim。
3. 运行 `:MasonInstallAll`，安装 stylua、ruff、prettier、sqlfluff 等非 LSP 工具。
4. mason-lspconfig 会根据 `ensure_installed` 安装所需 LSP；可在 `:Mason` 查看状态。
5. 运行 `:checkhealth`。

## 常用命令

| 命令                     | 作用                             |
| ------------------------ | -------------------------------- |
| `:Lazy`                  | 插件管理器                       |
| `:Mason`                 | LSP / Formatter / Linter 管理器  |
| `:MasonInstallAll`       | 安装配置声明的非 LSP 工具        |
| `:LspInfo`               | 查看当前 Buffer 的 LSP           |
| `:ConformInfo`           | 查看格式化器状态                 |
| `:checkhealth`           | 健康检查                         |
| `:FormatDisable`         | 全局禁用自动格式化               |
| `:FormatDisable!`        | 仅当前 Buffer 禁用自动格式化     |
| `:FormatEnable`          | 清除全局和当前 Buffer 的禁用状态 |
| `:MarkdownPreviewToggle` | 浏览器预览 Markdown              |

## 快捷键速查

- **搜索**：`<leader>ff` 文件，`<leader>fw` 全局文本，`<leader>fb` Buffer
- **文件树**：`<leader>ee` 开关，`<leader>eo` 聚焦
- **Buffer**：`<leader>bn` / `<leader>bp` 切换，`<leader>bd` 安全关闭
- **LSP**：`gd` 定义，`gr` 引用，`K` 文档，`<leader>ca` Code Action
- **诊断**：`[d` / `]d` 跳转，`<leader>de` 查看详情
- **Trouble**：`<leader>xx` 全局诊断，`<leader>xb` 当前 Buffer，`<leader>xt` TODO
- **格式化**：`<leader>cf`
- **原生注释**：`gcc` 当前行，Visual `gc` 选区
- **Surround**：`saiw)` 添加，`sd'` 删除，`sr'"` 替换
- **Git**：`[g` / `]g` 切换 hunk，`<leader>gp` 预览 hunk
- **Claude Code**：`<leader>ac`
- **Pi**：`<leader>pp` 对话框，Visual `<leader>pp` 携带选区，`<leader>ps` 发送选区

完整说明见 [Neovim-guide.md](./Neovim-guide.md)。维护配置请阅读 [MAINTENANCE.md](./MAINTENANCE.md)。

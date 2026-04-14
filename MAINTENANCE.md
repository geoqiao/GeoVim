# MAINTENANCE.md

本文档面向维护者，说明如何修改、扩展和排查本 Neovim 配置。

---

## 核心架构原则

1. **Neovim 0.12+ 原生 LSP API**
   - 使用 `vim.lsp.config(name, opts)` 定义服务器
   - 使用 `vim.lsp.enable(name)` 启用服务器
   - Buffer 级键位和补全统一在 `lua/autocmds.lua` 的 `LspAttach` 事件里绑定
   - `lspconfig` 仅作为 mason-lspconfig 的 fallback 存在

2. **无 nvim-cmp**
   - 所有补全靠 `vim.lsp.completion.enable()`（Neovim 0.10+ 原生）
   - 如需更强的补全体验，可以自行添加 `nvim-cmp` + `cmp-nvim-lsp`

3. **lazy.nvim 插件组织模式**
   - `lua/plugins/init.lua` 只负责 `import`，不写具体配置
   - 每个插件/插件组一个独立文件，return lazy spec

---

## 添加新插件

1. 在 `lua/plugins/` 下新建一个 `.lua` 文件，例如 `myplugin.lua`
2. 写入 lazy spec：

   ```lua
   return {
     {
       "author/plugin-name",
       event = "VeryLazy",
       config = function()
         require("plugin-name").setup({})
       end,
     },
   }
   ```

3. 在 `lua/plugins/init.lua` 中添加：

   ```lua
   { import = "plugins.myplugin" },
   ```

4. 重启 Neovim，运行 `:Lazy` 确认加载无误

---

## 添加新 LSP 服务器

以 `rust_analyzer` 为例：

1. **确保工具已安装**：运行 `:Mason` 或 `:MasonInstall rust-analyzer`
2. **在 `lua/plugins/lsp.lua` 中添加配置**：

   ```lua
   vim.lsp.config("rust_analyzer", {
     root_markers = { "Cargo.toml", ".git" },
   })
   vim.lsp.enable("rust_analyzer")
   ```

3. **在 `lua/plugins/mason.lua` 的 `ensure_installed` 列表中加入**：

   ```lua
   "rust_analyzer",
   ```

4. 重启 Neovim，打开对应类型文件，运行 `:LspInfo` 确认服务器已连接

> 不需要写 `on_attach`！所有 buffer 级通用行为都在 `lua/autocmds.lua` 的 `LspAttach` 里统一处理。

---

## 添加新格式化器

以 `shfmt`（Shell 脚本）为例：

1. **安装工具**：`:MasonInstall shfmt`
2. **在 `lua/plugins/conform.lua` 中注册**：

   ```lua
   formatters_by_ft = {
     -- 已有配置 ...
     sh = { "shfmt" },
   }
   ```

3. **在 `lua/plugins/mason.lua` 的 `mason-tool-installer` 中加入**：

   ```lua
   "shfmt",
   ```

4. 保存 shell 脚本文件，观察是否自动格式化

---

## 添加新 Linter

以 `shellcheck` 为例：

1. **安装工具**：`:MasonInstall shellcheck`
2. **在 `lua/plugins/lint.lua` 中注册**：

   ```lua
   lint.linters_by_ft = {
     -- 已有配置 ...
     sh = { "shellcheck" },
   }
   ```

3. 保存文件或离开 Insert 模式时，自动触发 lint

---

## 键位映射规范

- **全局映射**统一写在 `lua/keymaps.lua`
- **Buffer 级映射**（LSP、Git 等）统一写在 `lua/autocmds.lua` 或对应插件的 `on_attach` 里
- Leader 键是 `<Space>`
- 不覆盖 `hjkl`、`y`/`p`、`Ctrl-o`/`Ctrl-i` 等原生核心键位
- `<Tab>`  intentionally 不映射，避免破坏 jump list

---

## 格式化本仓库的 Lua 代码

```bash
stylua .
```

配置见 `.stylua.toml`（4 空格缩进，120 列宽，优先双引号）。

---

## 常见排查

### `:Lazy update` 时 markdown-preview.nvim 报错 "local changes"

**原因**：旧版 build 命令 `cd app && npm install` 会在插件目录生成 `yarn.lock`，导致 git working tree dirty。  
**修复**：已改用官方推荐的 `build = function() vim.fn["mkdp#util#install"]() end`。如果本地仍报错，删除插件目录后重装：

```bash
rm -rf ~/.local/share/nvim/lazy/markdown-preview.nvim
```

然后在 Neovim 里运行 `:Lazy install`。

### 打开文件后 LSP 没有启动

1. 运行 `:Mason` 确认对应服务器已安装
2. 运行 `:LspInfo` 查看当前 buffer 已连接的客户端
3. 检查 `lua/plugins/lsp.lua` 中是否对该服务器调用了 `vim.lsp.enable(name)`

### 保存时没有自动格式化

1. 运行 `:ConformInfo` 查看 conform 是否识别当前文件类型
2. 检查 `lua/plugins/conform.lua` 中 `formatters_by_ft` 是否包含该类型
3. 确认对应 formatter 已通过 Mason 安装

### 主题没有生效或启动时闪默认色

- `theme.lua` 中 `lazy = false` 和 `priority = 1000` 确保主题最先加载
- `init.lua` 末尾的 `vim.cmd("colorscheme catppuccin-frappe")` 是冗余保险，若删除需确保 `theme.lua` 的 `config` 中已设置
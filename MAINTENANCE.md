# MAINTENANCE.md

本文档面向 GeoVim 维护者，说明架构、扩展方式和验证流程。

## 核心架构

### Neovim 0.12+ 原生 LSP

- `nvim-lspconfig` 提供 server 默认定义。
- `lua/plugins/lsp.lua` 使用 `vim.lsp.config(name, opts)` 扩展配置，并用 `vim.lsp.enable(name)` 显式启用。
- `mason-lspconfig.automatic_enable = false`，避免与 `lsp.lua` 重复启用。
- 通用 Buffer 键位及 ESLint 保存修复位于 `lua/autocmds.lua` 的 `LspAttach`。
- blink.cmp 在 LSP 启动前注入 capabilities。

### 插件组织

- `init.lua` 使用 `spec = { import = "plugins" }` 自动扫描 `lua/plugins/*.lua`。
- **不存在** `lua/plugins/init.lua`。
- 全局 `defaults.lazy = true`，每个 spec 必须声明 `lazy = false`、`event`、`cmd`、`keys` 或 `ft`。
- 优先使用最具体的触发器：命令型插件用 `cmd`，快捷键入口用 `keys`，文件类型能力用 `ft`。

### 格式化与 Lint

- Conform 通过 `format_on_save` 统一格式化，LSP 仅作为 fallback。
- Python 顺序为 `ruff_organize_imports` → `ruff_format`。
- SQLFluff exit code 1 表示仍有不可修复违规，但已生成的修复结果仍会应用。
- Lua/Python 在 `InsertLeave` 和 `BufWritePost` lint；SQL 只在 `BufWritePost` lint。
- `:FormatDisable` 全局禁用，`:FormatDisable!` 仅禁用当前 Buffer，`:FormatEnable` 恢复。

## 添加插件

在 `lua/plugins/` 新建文件并返回 lazy spec：

```lua
return {
    {
        "author/plugin-name",
        cmd = "PluginCommand",
        opts = {},
    },
}
```

不要无条件使用 `VeryLazy`。根据实际入口选择：

- 用户命令：`cmd`
- 快捷键：`keys`
- 文件类型：`ft`
- Buffer 生命周期：`BufReadPre` / `BufNewFile`
- 主题：`lazy = false` + 高 `priority`

## 添加 LSP

以 `rust_analyzer` 为例：

1. 在 `lua/plugins/lsp.lua` 中配置并启用：

   ```lua
   vim.lsp.config("rust_analyzer", {
       root_markers = { "Cargo.toml", ".git" },
   })
   vim.lsp.enable("rust_analyzer")
   ```

2. 在 `lua/plugins/mason.lua` 的 mason-lspconfig `ensure_installed` 中加入 `"rust_analyzer"`。
3. 重启 Neovim，打开 Rust 文件并运行 `:LspInfo`。

通用键位不要复制到 server 配置；统一由 `LspAttach` 管理。

## 添加 Formatter

1. 在 `lua/plugins/conform.lua` 的 `formatters_by_ft` 注册。
2. 如果工具由 Mason 管理，在 mason-tool-installer 的 `ensure_installed` 中加入包名。
3. 用 `:ConformInfo` 检查可用性，并保存测试文件验证真实输出。

## 添加 Linter

1. 在 `lua/plugins/lint.lua` 的 `linters_by_ft` 注册。
2. 在 `lua/autocmds.lua` 中明确触发策略；重型工具优先只在保存后运行。
3. 用包含真实违规的文件验证 diagnostics。

## 数据安全约定

- `swapfile = true`：支持崩溃恢复和并发编辑检测。
- `writebackup = true`：避免写入中断损坏原文件。
- Bufferline 不允许强制关闭 modified buffer。
- 长期 `backup` 文件保持关闭。

## Mason 工具管理

- mason-lspconfig 根据 `ensure_installed` 管理 LSP。
- mason-tool-installer 设置 `run_on_start = false`，避免启动时联网。
- `:MasonInstallAll` 手动安装 stylua、ruff、prettier、sqlfluff。
- `luacheck` 通过 Homebrew 管理，避免当前 Mason/Lua 版本兼容问题。

## 验证命令

```bash
stylua --check .
luacheck init.lua lua --globals vim --no-color
git diff --check
nvim --headless -u ./init.lua +qa
```

功能修改还应执行对应用户流程：

- LSP：`:LspInfo`
- Formatter：`:ConformInfo` 并检查格式化后的文件
- 插件触发：确认首次按键/命令能从未加载状态启动插件
- 图片：在支持 Sixel 的真实终端中验证
- 最终运行 `:checkhealth`

## 常见排查

### LSP 没有启动

1. `:Mason` 确认 server 已安装。
2. `:LspInfo` 查看客户端与 root directory。
3. 检查 `lsp.lua` 是否同时调用 `vim.lsp.config` 和 `vim.lsp.enable`。
4. 新安装 server 后重启 Neovim。

### 自动格式化没有执行

1. `:ConformInfo` 检查 formatter 和命令路径。
2. 检查 filetype 是否在 `formatters_by_ft`。
3. 执行 `:FormatEnable` 清除禁用状态。
4. SQL 检查 `sqlfluff-sparksql.cfg` 是否存在。

### Markdown 预览失败

确认 Node.js/npm 可用，然后在 lazy.nvim 中重新 build `markdown-preview.nvim`。

### 图片不显示

1. `magick -list format | grep -i sixel` 确认 ImageMagick 支持 Sixel。
2. 确认终端支持 Sixel；当前配置针对 Ghostty。
3. 在 Markdown 或直接打开 PNG/JPEG 文件以触发 image.nvim。

### 主题启动闪烁

`theme.lua` 必须保持 `lazy = false`、`priority = 1000`，并应用 `colorscheme neodarcula`。

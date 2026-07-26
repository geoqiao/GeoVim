# MAINTENANCE.md

本文档面向 GeoVim 维护者，说明架构、扩展方式和验证流程。

## 核心架构

### Neovim 0.12+ 原生 LSP

- `nvim-lspconfig` 提供 server 默认定义。
- `lua/plugins/lsp.lua` 使用 `vim.lsp.config(name, opts)` 扩展配置，并用 `vim.lsp.enable(name)` 显式启用。
- `mason-lspconfig.automatic_enable = false`，避免与 `lsp.lua` 重复启用。
- 通用 Buffer 键位及 ESLint 保存修复位于 `lua/autocmds.lua` 的 `LspAttach`。
- `gri`、`grr`、`K` 等导航使用 Neovim 0.12 原生 LSP 映射，不再覆盖 `gi` / `gr`。
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
- Lua、Python、SQL 均只在 `BufWritePost` lint；实时语法和类型反馈由 LSP 负责。
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

## 项目根目录约定

- `lua/project.lua` 是 Telescope、nvim-tree 和 Pi session 匹配的唯一 root resolver。
- 优先识别最近的 `.git`、语言包管理文件、`.marksman.toml` 或 `.obsidian`。
- 没有 marker 时回退到当前文件目录；不要启用 `autochdir`。
- Marksman 额外使用 `.marksman.toml`、`.obsidian`、`.git` 形成 Markdown workspace。

## Pi session 安全

- `lua/pi_session.lua` 验证 Unix socket、PID 和 Pi 进程身份，过滤退出异常或 PID 复用留下的陈旧记录，并禁止跨项目 fallback。
- 必须先通过本机进程及祖先确认 Pi 身份；extension metadata 只补充角色、不能绕过身份验证。当前项目只有一个已确认主候选时自动连接，身份未知或多个候选时 fail closed，必须用 `<leader>pS` 明确选择。
- 手动选择会固定到该 session；目标退出后自动解除，并重新按安全规则解析。

## 数据安全约定

- `swapfile = true`：支持崩溃恢复和并发编辑检测。
- `writebackup = true`：避免写入中断损坏原文件。
- `.env`、`*.env`、PEM / key 和常见 SSH 私钥通过 `lua/security.lua` 禁用 persistent undo、swap 和临时备份；`:saveas` / `:file` 改名后同样生效。
- `download_remote_images = true` 是明确保留的产品选择，不应被安全清理误改。
- Bufferline 不允许强制关闭 modified buffer。
- 长期 `backup` 文件保持关闭。

## Mason 工具管理

- mason-lspconfig 根据 `ensure_installed` 管理 LSP。
- mason-tool-installer 设置 `run_on_start = false`，避免启动时联网。
- `:MasonInstallAll` 手动安装 stylua、ruff、prettier、sqlfluff。
- `luacheck` 通过 Homebrew 管理，避免当前 Mason/Lua 版本兼容问题。
- lazy.nvim 的 LuaRocks 管线保持关闭；image.nvim 使用 `magick_cli` 且显式 `build = false`。

## 验证命令

完整检查统一使用：

```bash
./scripts/check.sh
```

它会执行 StyLua、Luacheck、Prettier、Git whitespace 检查，以及 `scripts/smoke.lua` 中的 Headless 行为断言。Smoke test 覆盖 filetype profile、project root、敏感文件、Pi fail-closed 路由、lazy trigger、远程图片配置和 LuaRocks 状态。

功能修改还应执行对应用户流程：

- LSP：`:LspInfo`
- Formatter：`:ConformInfo` 并检查格式化后的文件
- 插件触发：确认首次按键/命令能从未加载状态启动插件
- 图片：在支持 Kitty Graphics Protocol 的真实终端中验证
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

1. `magick -version` 确认 ImageMagick CLI 可用。
2. 确认终端支持 Kitty Graphics Protocol；当前配置针对 Ghostty，Ghostty 不支持 Sixel。
3. 在 Markdown 或直接打开 PNG/JPEG 文件以触发 image.nvim，并确认彩色图片实际可见。
4. Markdown 远程图片下载保持启用；排查网络图片时同时检查 URL 可达性。

### 主题启动闪烁

`theme.lua` 必须保持 `lazy = false`、`priority = 1000`，并应用 `colorscheme neodarcula`。

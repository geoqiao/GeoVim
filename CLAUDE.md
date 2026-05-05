# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal Neovim configuration written in Lua, targeting Neovim 0.12+. It is a fully independent config that does **not** rely on NvChad. All config comments and documentation are written in Chinese.

## Requirements

- **Neovim >= 0.12** (hard check at top of `init.lua`)
- `stylua` for Lua formatting (if available)

## Common Commands

Since this is a Neovim config, there is no traditional build or test suite. Common development tasks use the following tools and Neovim commands:

- **Format Lua files:** `stylua .` (config in `.stylua.toml` — 4-space indentation, 120 column width, auto-prefer double quotes)
- **Check formatting without writing:** `stylua --check .`
- **Open plugin manager:** `:Lazy` (lazy.nvim)
- **Open tool installer:** `:Mason` (installs LSPs, formatters, linters)
- **Install all required tools:** `:MasonInstallAll`
- **Health check:** `:checkhealth`
- **Reload config after editing:** restart Neovim, or run `:luafile %` on the current file

## Architecture

### Entry Point and Loading Order

`init.lua` bootstraps `lazy.nvim` if missing, then loads three core modules in this order:

1. `lua/options.lua` — editor settings (tabs, line numbers, clipboard, diagnostics, etc.)
2. `lua/autocmds.lua` — autocommands (cursor restore, yank highlight, LSP attach, auto-lint)
3. `lua/keymaps.lua` — all keymaps

After the core modules, `init.lua` calls `require("lazy").setup({ spec = { import = "plugins" } })`, which causes lazy.nvim to automatically import **every** `.lua` file in `lua/plugins/` via directory scan.

### Plugin Organization Pattern

- **No `lua/plugins/init.lua`** — lazy.nvim's `import = "plugins"` walks the directory automatically. Adding a new file under `lua/plugins/` is the only step required to register a plugin.
- Each plugin lives in its own file under `lua/plugins/` (e.g. `telescope.lua`, `lsp.lua`, `conform.lua`).
- Most plugin files return a lazy.nvim spec table. Each spec MUST declare a lazy trigger (`event`, `cmd`, `keys`, `ft`, or explicit `lazy = false`) because the global `defaults = { lazy = true }` in `init.lua` will otherwise leave it un-loaded. UI plugins like the colorscheme pin themselves with `lazy = false, priority = 1000`.
- A few plugins (like `claude-code.lua`) declare lazy `keys = {}` inside the spec rather than in the global `keymaps.lua`.

### LSP Architecture (Neovim 0.12+ Native API)

This config uses the **modern native LSP API**, not the classic `lspconfig` `setup()` pattern:

- Server configs are defined with `vim.lsp.config(name, opts)` in `lua/plugins/lsp.lua`.
- Servers are enabled with `vim.lsp.enable(name)`.
- **`mason-lspconfig` v2 schema:** the legacy `handlers = {}` field is gone; we use `automatic_enable = { exclude = { "pyright" } }` (see `lua/plugins/mason.lua`) so installed servers auto-enable except `pyright`, which would conflict with `ty` for Python.
- **Buffer-local keymaps and capabilities** are wired in `lua/autocmds.lua` inside an `LspAttach` autocommand. This includes:
  - Navigation: `gd`, `gr`, `gi`, `K`, `gD`
  - Actions: `<leader>cr` (rename), `<leader>ca`, `<leader>ds`, `<leader>ws`
  - **Completion via `blink.cmp`** (`lua/plugins/cmp.lua`); `vim.lsp.config('*', { capabilities = blink.get_lsp_capabilities() })` is injected at the top of `lsp.lua`'s config function. There is no `vim.lsp.completion.enable` call anymore.
  - ESLint Fix All on save (for `client.name == "eslint"` only)
- `LspDetach` autocmd cleans up buffer-local autocommands to prevent duplicates on `LspRestart`.

### Formatting Pipeline

- **Formatter:** `conform.nvim` (`lua/plugins/conform.lua`). Configured formatters:
  - Lua → `stylua`
  - Python → `ruff_format`, `ruff_organize_imports` (with `uv` auto-detection)
  - Web/JSON/YAML/Markdown → `prettier`
  - SQL → `sqlfluff`
- **Auto-format on save** is handled entirely by `conform.format_on_save` (inside conform.lua). There are **no external `BufWritePre` autocmds** for formatting.
- **Manual toggle commands**: `:FormatDisable` (buffer-local with `!`, or global) and `:FormatEnable`.

### Linting Pipeline

- **Linter:** `nvim-lint` (`lua/plugins/lint.lua`). Configured linters:
  - Lua → `luacheck` (passing `--globals vim love`)
  - Python → `ruff`
  - SQL → `sqlfluff`
- **Auto-lint** runs on `BufWritePost` and `InsertLeave` only (NOT `BufEnter`), with a `vim.list_contains` filetype filter (`lua | python | sql`) to avoid running on irrelevant filetypes.

### Keymap Design Philosophy

- Leader key is `<Space>`.
- The config follows a **pure Vim-native** style: classic motions like `hjkl`, `0$`, `ggG`, `u`, `Ctrl+r`, `;` (f/t repeat), and native yank/put are **not** overridden.
- **`<Tab>` is intentionally left untouched** because it is equivalent to `Ctrl-i` in Vim; remapping it would break the jump list (`Ctrl-o` / `Ctrl-i`).
- Buffer switching uses `<leader>bn` / `<leader>bp` (NOT `H`/`L`, which are reserved for screen-top/screen-bottom navigation).
- Claude Code integration uses `<leader>a*` prefix (e.g. `<leader>ac`) to avoid conflicting with the `<leader>c` (Code Action) group.
- Advanced features are grouped under `<leader>` sub-menus, with which-key providing prompts.

### Claude Code Integration

The `greggh/claude-code.nvim` plugin is configured in `lua/plugins/claude-code.lua`:
- `<leader>ac` — toggle Claude Code panel
- `<leader>aC` — continue previous conversation
- `<leader>aR` — resume conversation selector
- `<leader>aV` — verbose mode
- The panel opens as a vertical split on the left.
- If `claude` CLI is not in PATH, the plugin prints a warning and skips setup.

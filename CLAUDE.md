# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal Neovim configuration written in Lua, targeting Neovim 0.12+. It is a fully independent config that does **not** rely on NvChad (the README at the root is stale and refers to an old template). All config comments and documentation are written in Chinese.

## Common Commands

Since this is a Neovim config, there is no traditional build or test suite. Common development tasks use the following tools and Neovim commands:

- **Format Lua files:** `stylua .` (config in `.stylua.toml` — 4-space indentation, 120 column width, auto-prefer double quotes)
- **Check formatting without writing:** `stylua --check .`
- **Open plugin manager:** `:Lazy` (lazy.nvim)
- **Open tool installer:** `:Mason` (installs LSPs, formatters, linters)
- **Health check:** `:checkhealth`
- **Reload config after editing:** restart Neovim or run `:source %` on the current file

## Architecture

### Entry Point and Loading Order

`init.lua` bootstraps `lazy.nvim` if missing, then loads three core modules in this order:

1. `lua/options.lua` — editor settings (tabs, line numbers, clipboard, etc.)
2. `lua/autocmds.lua` — autocommands (cursor restore, yank highlight, LSP attach, auto-format, auto-lint)
3. `lua/keymaps.lua` — all keymaps

After the core modules, `init.lua` calls `require("lazy").setup({ spec = { import = "plugins" } })`, which causes lazy.nvim to automatically import **every** `.lua` file in `lua/plugins/`.

### Plugin Organization Pattern

- `lua/plugins/init.lua` only contains `import = "plugins.xxx"` declarations. It does not configure plugins directly.
- Each actual plugin lives in its own file under `lua/plugins/` (e.g. `telescope.lua`, `lsp.lua`, `conform.lua`).
- Most plugin files return a lazy.nvim spec table. A few (like `claude-code.lua`) also define `keys = {}` inside the spec rather than in the global `keymaps.lua`.

### LSP Architecture (Neovim 0.12+ Native API)

This config uses the **modern native LSP API**, not the classic `lspconfig` `setup()` pattern:

- Server configs are defined with `vim.lsp.config(name, opts)` in `lua/plugins/lsp.lua`.
- Servers are enabled with `vim.lsp.enable(name)`.
- **Buffer-local keymaps and capabilities** are wired in `lua/autocmds.lua` inside an `LspAttach` autocommand. This includes:
  - Navigation: `gd`, `gr`, `gi`, `K`, `gD`
  - Actions: `<leader>rn`, `<leader>ca`, `<leader>ds`, `<leader>ws`
  - Diagnostics: `[d`, `]d`, `<leader>d`
  - Native autocompletion via `vim.lsp.completion.enable()` (no separate completion plugin)
  - Auto-format on save (with a fallback guard to let `conform.nvim` take priority)

`mason-lspconfig.nvim` is present mainly to auto-install servers, but its default handler also calls `lspconfig[server].setup({})` for any server not explicitly handled. The explicit `vim.lsp.config/enable` calls in `lsp.lua` override this for the servers that are actively used.

### Formatting and Linting Pipeline

- **Formatter:** `conform.nvim` (`lua/plugins/conform.lua`). Configured formatters:
  - Lua → `stylua`
  - Python → `ruff_format`, `ruff_organize_imports` (with `uv` auto-detection)
  - Web/JSON/YAML/Markdown → `prettier`
  - SQL → `sqlfluff`
- **Linter:** `nvim-lint` (`lua/plugins/lint.lua`). Configured linters:
  - Lua → `luacheck` (with `--globals vim love`)
  - Python → `ruff`
  - SQL → `sqlfluff`
- **Auto-format on save** is triggered from `lua/autocmds.lua` (two separate `BufWritePre` autocommands: one for conform, one as LSP fallback).
- **Auto-lint** runs on `BufEnter`, `BufWritePost`, and `InsertLeave`, also in `lua/autocmds.lua`.

### Keymap Design Philosophy

- Leader key is `<Space>`.
- The config follows a **pure Vim-native** style: classic motions like `hjkl`, `0$`, `ggG`, `u`, `Ctrl+r`, and native yank/put are **not** overridden.
- Advanced features are grouped under `<leader>` sub-menus, with which-key providing prompts.
- **Important:** `<Tab>` is intentionally left untouched because it is equivalent to `Ctrl-i` in Vim; remapping it would break the jump list (`Ctrl-o` / `Ctrl-i`).
- Buffer switching uses `H` / `L`, which overrides the rarely-used `H`/`L` screen-line motions (use `zt`/`zb` instead).

### Claude Code Integration

The `greggh/claude-code.nvim` plugin is configured in `lua/plugins/claude-code.lua`:
- `<leader>cc` — toggle Claude Code panel
- `<leader>cC` — continue previous conversation
- `<leader>cR` — resume conversation selector
- The panel opens as a vertical split on the left, and files modified by Claude Code are auto-reloaded in Neovim.

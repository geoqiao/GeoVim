#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

for command_name in stylua luacheck prettier nvim; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'Missing required command: %s\n' "$command_name" >&2
        exit 1
    fi
done

printf '%s\n' '==> StyLua'
stylua --check .

printf '%s\n' '==> Luacheck'
luacheck init.lua lua scripts/smoke.lua --globals vim --no-color

printf '%s\n' '==> Markdown formatting'
prettier --check README.md MAINTENANCE.md Neovim-guide.md CLAUDE.md AGENTS.md

printf '%s\n' '==> Neovim smoke checks'
nvim --headless -u ./init.lua -l scripts/smoke.lua
printf '\n'

printf '%s\n' '==> Git whitespace checks'
git diff --check

printf '%s\n' 'All checks passed.'

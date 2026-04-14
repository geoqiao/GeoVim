-- ============================================
--  Neovim 启动入口 (init.lua)
-- ============================================
-- 这是一个完全独立、从零开始编写的配置，不依赖 NvChad。
-- 目标：简洁、现代、对新手极度友好。
-- 假设：Neovim 版本 >= 0.12（使用原生 LSP 新 API）

-- 设置 Leader 键为空格，必须在加载插件之前定义
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================
-- 第一步：安装 / 加载 lazy.nvim（插件管理器）
-- ============================================
-- lazy.nvim 会自动下载并管理所有其他插件
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

-- 把 lazy.nvim 加入运行时路径
vim.opt.rtp:prepend(lazypath)

-- ============================================
-- 第二步：加载我们自己的配置模块
-- ============================================
require("options")   -- 编辑器基本设置（行号、缩进等）
require("autocmds")  -- 自动命令（保存时格式化、LSP Attach 等）
require("keymaps")   -- 快捷键映射

-- ============================================
-- 第三步：加载所有插件
-- ============================================
-- lazy.nvim 会自动读取 lua/plugins/ 目录下的所有 .lua 文件
require("lazy").setup({
  spec = { import = "plugins" },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { "catppuccin" } },
  ui = {
    icons = {
      ft = "",
      lazy = "󰂠 ",
      loaded = "",
      not_loaded = "",
    },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },
})

-- ============================================
-- 第四步：应用主题
-- ============================================
-- 主题已在 lua/plugins/theme.lua 的 config 中设置

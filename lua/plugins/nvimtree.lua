-- ============================================
-- NvimTree：文件树侧边栏
-- ============================================
-- 类似于 VS Code 左侧的资源管理器，可以快速浏览、打开、创建、删除文件。

return {
  {
    "nvim-tree/nvim-tree.lua",
    event = "VeryLazy",
    dependencies = {
      -- 提供文件图标
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        -- 不要自动替换 netrw（Neovim 自带的文件浏览器）
        disable_netrw = true,
        hijack_netrw = true,
        -- 当用 Telescope 或其他方式打开文件时，自动更新文件树中的高亮位置
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        -- 文件树渲染设置
        renderer = {
          root_folder_label = false,
          highlight_git = true,
          indent_markers = {
            enable = true,
          },
          icons = {
            glyphs = {
              default = "󰈚",
              folder = {
                default = "󰉋",
                empty = "",
                empty_open = "",
                open = "",
                symlink = "",
              },
              git = { unmerged = "" },
            },
          },
        },
        -- 过滤掉不想看到的文件/文件夹
        filters = {
          dotfiles = false,
          custom = {
            "^.git$",
            "node_modules",
            ".venv",
            "__pycache__",
            ".mypy_cache",
          },
        },
        -- 文件树的窗口尺寸
        view = {
          width = 35,
          side = "left",
        },
        -- 在文件树中按 a 创建文件、按 d 删除文件时的确认弹窗
        actions = {
          open_file = {
            quit_on_open = false, -- 打开文件后不自动关闭文件树
          },
        },
      })
    end,
  },
}

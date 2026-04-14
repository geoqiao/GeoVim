# Neovim 使用指南

> 这是一个**从零开始重写**的现代 Neovim 配置，专为新手设计。  
> 不再依赖 NvChad，使用 Neovim 0.12+ 原生 LSP 新 API，结构清晰、注释详尽。  
> **快捷键采用纯粹的 Vim 原生风格**，帮助你逐步建立 Vim 肌肉记忆。

---

## 配置结构速览

```
~/.config/nvim/
├── init.lua                 -- 启动入口
├── lua/
│   ├── options.lua          -- 编辑器基本设置（行号、缩进、剪贴板等）
│   ├── autocmds.lua         -- 自动命令（保存格式化、光标恢复、LSP Attach 等）
│   ├── keymaps.lua          -- 所有快捷键
│   └── plugins/             -- 插件配置目录
│       ├── init.lua         -- 插件总列表
│       ├── theme.lua        -- 主题（TokyoNight）
│       ├── telescope.lua    -- 文件/文本搜索
│       ├── nvimtree.lua     -- 文件树
│       ├── lualine.lua      -- 底部状态栏
│       ├── bufferline.lua   -- 顶部 Buffer 标签
│       ├── whichkey.lua     -- 快捷键提示
│       ├── comment.lua      -- 快速注释
│       ├── treesitter.lua   -- 语法高亮
│       ├── mason.lua        -- 工具自动安装器
│       ├── lsp.lua          -- LSP 语言服务器（Neovim 0.12 原生 API）
│       ├── conform.lua      -- 代码格式化
│       ├── lint.lua         -- 代码检查
│       ├── gitsigns.lua     -- Git 增强
│       └── markdown.lua     -- Markdown 支持
└── Neovim-guide.md          -- 本文件
```

---

## 首次启动

首次打开 Neovim 时，`lazy.nvim` 会自动下载所有插件。请耐心等待下载完成，然后重启一次 Neovim。

重启后，运行以下命令安装开发工具：

```vim
:Mason
```

在弹出的 Mason 窗口中，你可以看到已安装和待安装的工具。等界面显示所有工具都是绿色 ✓ 后，即可退出（按 `q`）。

如果 Mason 没有自动安装某个工具，也可以手动执行：

```vim
:MasonInstall lua-language-server basedpyright typescript-language-server eslint-lsp prettier sqlfluff sqlls json-lsp yaml-language-server marksman ruff stylua
```

---

## Vim 新手入门教程

> 如果你从没用过 Vim，请务必花 5 分钟读完本节。理解 Vim 的**三种模式**，比背快捷键更重要。

### 一、三种模式是什么？有什么区别？

#### 1. Normal 模式（正常模式）

**这是 Vim 的“主模式”**，你按 `Esc` 或 `jk` 就会回到这里。

- **特点**：你输入的每个字母都是**命令**，不是文字。
- **能做什么**：移动光标、复制、删除、保存、跳转、撤销……
- **进入方式**：
  - 按 `Esc`
  - 或按 `jk`（更快，手不用离开主键区）

**例子**：
- 你按 `j`，光标向下移动一行
- 你按 `dd`，删除当前整行
- 你按 `u`，撤销刚才的操作
- 你按 `:` 进入命令行，可以保存/退出

#### 2. Insert 模式（插入模式）

**这就是普通编辑器的“打字模式”**，你输入的字母会直接变成文字。

- **特点**：你可以像用记事本一样打字。
- **能做什么**：只能打字、删除前面的字（Backspace）。
- **进入方式**（从 Normal 模式）：
  - 按 `i`：在光标**前**插入
  - 按 `a`：在光标**后**插入
  - 按 `o`：在**下一行**新建空行并插入

**如何回到 Normal 模式**：
- 按 `Esc`
- 或按 `jk`

#### 3. Visual 模式（可视模式）

**这就是“选中模式”**，类似你用鼠标拖选文字。

- **特点**：你移动光标时，会**高亮选中**一片区域，然后可以对它执行操作（复制、删除、注释、缩进）。
- **进入方式**（从 Normal 模式）：
  - 按 `v`：进入**字符选中**（选中一个字符一个字符地扩展）
  - 按 `V`：进入**行选中**（直接选中整行）
  - 按 `Ctrl+v`：进入**块选中**（选中一个矩形区域）

**如何回到 Normal 模式**：
- 按 `Esc`
- 或按 `jk`

### 二、模式切换流程图

```
              按 i / a / o
    ┌─────────────────────────────┐
    │                             ▼
Normal ◄──── Esc / jk ──────► Insert
    │                             │
    │ 按 v / V / Ctrl+v           │
    ▼                             │
Visual ────── Esc / jk ──────►────┘
```

### 三、如何选中整行、复制、粘贴？

#### 选中整行（最简单）

| 步骤 | 按键 | 说明 |
|------|------|------|
| 确保在 Normal 模式 | `Esc` 或 `jk` | |
| 按 `V` | `V` | 进入 Visual 行模式，当前整行被高亮选中 |
| 移动光标 | `j` 或 `k` | 选中多行（按 `j` 向下扩展，按 `k` 向上扩展） |

**图示**：
```
按 V 前：        按 V 后：        再按 j 后：
 光标            整行高亮         两行高亮
   ↓               ↓↓↓             ↓↓↓
  hello           hello           hello
  world           world           world
  foo             foo             foo
```

#### 复制（Yank）

Vim 中“复制”叫做 **yank**，按键是 `y`。

- **方式 1**：在 **Normal 模式** 下，直接按 `yy`，当前整行就被复制了。
- **方式 2**：先用 `v` 或 `V` 进入 Visual 模式选中内容，然后按 `y`，选中的内容就被复制了。

#### 粘贴（Put）

按键是 `p` 或 `P`。

| 按键 | 效果 |
|------|------|
| `p` | 在光标**后面**粘贴 |
| `P` | 在光标**前面**粘贴 |

**整行粘贴**的特殊规则：
- 如果你用 `yy` 复制了一行，按 `p` 会在**当前行的下一行**粘贴
- 按 `P` 会在**当前行的上一行**粘贴

### 四、一个完整的例子

假设你要把第 3 行复制到第 5 行下面：

```
1: def hello():
2:     print("hi")
3:     return 42      <-- 你想复制这一行
4:
5: def world():
```

**操作步骤**：

1. `Esc` 确保在 Normal 模式
2. 用 `j` 或 `3gg` 移到第 3 行
3. `yy` 复制当前整行
4. 用 `j` 或 `5gg` 移到第 5 行
5. `p` 粘贴

**结果**：第 6 行会出现 `return 42`

### 五、删除和剪切的区别

Vim 中 `d` 既是“删除”也是“剪切”：

| 按键 | 作用 |
|------|------|
| `dd` | 删除（剪切）当前整行 |
| `dw` | 删除（剪切）从光标到单词末尾 |
| `d$` | 删除（剪切）从光标到行尾 |
| `x` | 删除（剪切）光标下的一个字符 |

- 如果你删除后按 `p`，就是**剪切**
- 如果你删除后不按 `p`，就是**删除**

### 六、入门必练小练习

打开任意文件，跟着做一遍：

1. 按 `Esc` 确保在 Normal
2. 按 `V` 选中当前行
3. 按 `j` 再往下选中一行
4. 按 `y` 复制这两行
5. 按 `Esc` 回到 Normal
6. 按 `p` 粘贴
7. 按 `u` 撤销

如果你能顺畅做完这 7 步，你就已经掌握了 Vim 最精华的部分。

---

## 核心快捷键（纯粹 Vim 原生风格）

> `<leader>` = **空格键** `Space`
>
> **重要提示**：按空格键后稍等 0.3 秒，屏幕底部会弹出 which-key 提示面板，告诉你接下来可以按什么键。**忘了快捷键的时候先按空格。**

### 最基础的操作（唯一保留的现代妥协）

| 快捷键 | 作用 |
|--------|------|
| `jk` | 退出 Insert 模式（等于按 Esc） |
| `;` | 进入命令模式（等于按 Shift+:`） |
| `Ctrl+S` | 保存文件 |

### Vim 原生光标移动（不覆盖，必须学会）

| 按键 | 作用 |
|------|------|
| `h` `j` `k` `l` | 左、下、上、右 |
| `w` | 跳到下一个单词开头 |
| `b` | 跳到上一个单词开头 |
| `e` | 跳到当前单词结尾 |
| `0` | 跳到行首 |
| `^` | 跳到行首第一个非空字符 |
| `$` | 跳到行尾 |
| `gg` | 跳到文件开头 |
| `G` | 跳到文件末尾 |
| `Ctrl+U` | 向上翻半页 |
| `Ctrl+D` | 向下翻半页 |

### 选中、复制、剪切、粘贴（Vim 原生）

| 按键 | 作用 |
|------|------|
| `v` | 进入 Visual（字符选中）模式 |
| `V` | 选中当前整行 |
| `Ctrl+V` | 进入块选中模式（Visual Block） |
| `viw` | 选中光标下的单词 |
| `y` | 复制（yank）选中的内容 |
| `yy` | 复制当前整行 |
| `d` | 剪切（delete）选中的内容 |
| `dd` | 剪切当前整行 |
| `p` | 在光标后粘贴 |
| `P` | 在光标前粘贴 |
| `u` | 撤销 |
| `Ctrl+R` | 重做 |

> Vim 的 `y`/`p` 默认使用 Neovim 的内部寄存器。如果你需要和系统剪贴板交互，使用下面的 leader 备用键。
>
> 备用：`leader + y` = 复制到系统剪贴板，`leader + Y` = 复制整行到系统剪贴板。

### 行移动与缩进（Vim 原生）

| 按键 | 作用 |
|------|------|
| `>>` | 当前行向右缩进 |
| `<<` | 当前行向左缩进 |
| `:m +1` | 下移当前一行 |
| `:m -2` | 上移当前一行 |
| `Visual 模式下 J` | 下移选中的多行 |
| `Visual 模式下 K` | 上移选中的多行 |
| `Visual 模式下 >` | 向右缩进并保持选中 |
| `Visual 模式下 <` | 向左缩进并保持选中 |

### Telescope 搜索（基于 leader）

| 快捷键 | 作用 | 记忆技巧 |
|--------|------|----------|
| `<leader>ff` | 查找文件 | **f**ind **f**iles |
| `<leader>fw` | 全局文本搜索 | **f**ind **w**ord |
| `<leader>fb` | 查找已打开的 Buffer | **f**ind **b**uffer |
| `<leader>fo` | 最近打开的文件 | **f**ind **o**ldfiles |
| `<leader>fh` | 搜索帮助文档 | **f**ind **h**elp |
| `<leader>fk` | 搜索快捷键 | **f**ind **k**eymaps |
| `<leader>fc` | 搜索光标下的单词 | **f**ind **c**ursor word |

### 文件树

| 快捷键 | 作用 |
|--------|------|
| `<leader>eee` | 显示/隐藏文件树 |
| `<leader>eeo` | 聚焦文件树 |

### Buffer（标签页）管理

| 快捷键 | 作用 |
|--------|------|
| `Tab` / `Shift+Tab` | 下一个 / 上一个 Buffer |
| `<leader>x` | 关闭当前 Buffer |
| `<leader>X` | 关闭其他所有 Buffer，保留当前 |

### 窗口分屏管理

| 快捷键 | 作用 |
|--------|------|
| `Ctrl+H/J/K/L` | 在分屏窗口间跳转 |
| `<leader>sh` | 水平分屏 |
| `<leader>sv` | 垂直分屏 |
| `Ctrl+↑/↓/←/→` | 调整分屏窗口大小 |

### LSP 代码操作

| 快捷键 | 作用 |
|--------|------|
| `gd` | 跳转到定义 (Go to Definition) |
| `gr` | 查看引用 (References) |
| `gi` | 跳转到实现 (Implementation) |
| `K` | 悬浮查看文档 (Hover) |
| `<leader>rn` | 重命名符号 (Rename) |
| `<leader>ca` | 代码动作（自动修复等） |
| `<leader>ds` | 文档符号 |
| `<leader>ws` | 工作区符号 |
| `<leader>f` | 格式化当前文件 |
| `[d` / `]d` | 上一个 / 下一个诊断（错误/警告） |
| `<leader>d` | 查看当前诊断详情 |

### 注释

| 快捷键 | 作用 |
|--------|------|
| `gcc` | 注释 / 取消注释当前行（Normal 模式） |
| `gc` | 注释 / 取消注释选中内容（Visual 模式） |
| `gbc` | 块注释（Normal 模式） |
| `gb` | 块注释（Visual 模式） |

### Git

| 快捷键 | 作用 |
|--------|------|
| `<leader>gb` | Blame 当前行 |
| `<leader>gp` | 预览当前 hunk |
| `<leader>gr` | 撤销当前 hunk |
| `]g` / `[g` | 下一个 / 上一个 hunk |

### Markdown

| 快捷键 | 作用 |
|--------|------|
| `<leader>mp` | 浏览器实时预览 |

> 注：`render-markdown.nvim`（编辑器内渲染）目前与 Neovim 0.12 + Treesitter 存在兼容性崩溃，为了保证稳定性，暂时只保留浏览器预览。后续上游修复后会重新启用。

---

## Python 开发（uv + ruff + basedpyright）

### 项目初始化

```bash
uv init my-project
cd my-project
uv venv
uv add requests
```

### 推荐配置（`pyproject.toml`）

```toml
[tool.ruff]
target-version = "py311"
line-length = 88

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W", "UP", "B", "SIM", "C4"]
```

### Neovim 行为（自动识别 `.venv`）

- 保存时自动用 `ruff format` 格式化
- 保存时自动用 `ruff` 整理 imports
- 实时 `ruff check` 诊断
- **`ty`（默认）提供类型提示和自动补全**：对 uv 和 `.venv` 的兼容性远好于 basedpyright
- **已包含 workaround**：针对 ty + Neovim 偶发的诊断丢失问题，配置了 `BufEnter` 自动刷新

### 切换回 `basedpyright`（备用选项）

如果你更习惯 basedpyright，编辑 `~/.config/nvim/lua/plugins/lsp.lua`：

1. 注释掉 `ty` 部分
2. 取消 `basedpyright` 部分的注释
3. 同时修改 `~/.config/nvim/lua/plugins/mason.lua`，把 `ensure_installed` 里的 `"ty"` 改回 `"basedpyright"`

然后运行：

```vim
:MasonInstall basedpyright
```

重启 Neovim 即可。

---

## JS / TS 开发

项目安装依赖：

```bash
npm install -D typescript eslint prettier eslint-config-prettier
```

保存时自动：
- `prettier` 格式化
- `eslint` 自动修复
- `ts_ls` 类型提示与补全

---

## SQL 开发

项目配置 `.sqlfluff`（按需改方言）：

```ini
[sqlfluff]
dialect = postgres
```

保存自动格式化，`sqlls` 提供补全。

---

## 常见问题

### LSP 没启动
```vim
:LspInfo      -- 查看哪些 LSP 已连接
:Mason        -- 查看工具是否已安装
```

### 格式化不工作
```vim
:ConformInfo
```

### 快捷键忘了
```vim
:Telescope keymaps
```
或者按 **空格键**，which-key 会弹出提示。

### 重新加载配置
```vim
:source ~/.config/nvim/init.lua
```

### 配置升级/回退
每次修改配置前，当前配置会自动备份到：
```
~/.config/nvim-backup-YYYYMMDD-HHMMSS/
```
如果新配置出问题，可以把备份目录改回 `nvim` 即可恢复。

---

## 快速备忘

| 场景 | 按键 |
|------|------|
| 查找文件 | `<leader>ff` |
| 全局搜索 | `<leader>fw` |
| 保存 | `Ctrl+S` |
| 退出 Insert | `jk` |
| 命令模式 | `;` |
| 注释 | `gcc` 或 `gc` |
| 格式化 | `<leader>f` |
| 跳定义 | `gd` |
| 重命名 | `<leader>rn` |
| 代码修复 | `<leader>ca` |
| 跳到行首 | `0` 或 `^` |
| 跳到行尾 | `$` |
| 选中整行 | `V` |
| 选中单词 | `viw` |
| 复制一行 | `yy` |
| 删除一行 | `dd` |
| 撤销 / 重做 | `u` / `Ctrl+R` |
| 复制到系统剪贴板 | `<leader>y` |
| 切换 Buffer | `Tab` / `Shift+Tab` |
| 关闭 Buffer | `<leader>x` |
| 文件树 | `<leader>eee` |
| Markdown 浏览器预览 | `<leader>mp` |
| 忘记快捷键时 | **按空格** |

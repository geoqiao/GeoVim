local failures = {}
local checks = 0

local function check(condition, message)
    checks = checks + 1
    if not condition then
        failures[#failures + 1] = message
    end
end

local function realpath(path)
    return vim.uv.fs_realpath(path) or vim.fs.normalize(path)
end

local profile_callback
for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ group = "editor_profiles", event = "FileType" })) do
    profile_callback = autocmd.callback
end
check(type(profile_callback) == "function", "editor_profiles 必须注册 FileType callback")

local function with_filetype(filetype, callback)
    local previous = vim.api.nvim_get_current_buf()
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buf)

    -- 只执行待测的 profile callback，避免 smoke test 因 FileType 懒加载图片等无关插件。
    local eventignore = vim.o.eventignore
    vim.o.eventignore = eventignore == "" and "FileType" or eventignore .. ",FileType"
    vim.bo[buf].filetype = filetype
    vim.o.eventignore = eventignore
    profile_callback({ buf = buf, event = "FileType" })

    callback(buf)
    if not vim.api.nvim_buf_is_valid(previous) then
        previous = vim.api.nvim_create_buf(false, true)
    end
    vim.api.nvim_set_current_buf(previous)
    vim.api.nvim_buf_delete(buf, { force = true })
end

check(vim.fn.has("nvim-0.12") == 1, "Neovim 必须 >= 0.12")
check(vim.o.colorcolumn == "", "全局 colorcolumn 应为空")
check(vim.o.wrap == false, "普通文件默认不应换行显示")

local terminal_map = vim.fn.maparg("<Esc><Esc>", "t", false, true)
check(type(terminal_map) == "table" and terminal_map.rhs == "<C-\\><C-n>", "终端模式应使用双 Esc 退出")
check(vim.fn.maparg("<Esc>", "t") == "", "终端模式单次 Esc 必须保留给 TUI")

with_filetype("typescript", function(buf)
    check(vim.bo[buf].shiftwidth == 2, "TypeScript shiftwidth 应为 2")
    check(vim.bo[buf].tabstop == 2, "TypeScript tabstop 应为 2")
    check(vim.wo.wrap == false, "TypeScript 不应自动换行显示")
end)

with_filetype("python", function(buf)
    check(vim.bo[buf].shiftwidth == 4, "Python shiftwidth 应为 4")
    check(vim.wo.colorcolumn == "", "Python 不应显示 ColorColumn")
end)

with_filetype("markdown", function(_)
    check(vim.wo.wrap == true, "Markdown 应换行显示")
    check(vim.wo.linebreak == true, "Markdown 应按单词边界换行")
    check(vim.wo.breakindent == true, "Markdown 折行应保留缩进")
end)

local lint_autocmds = vim.api.nvim_get_autocmds({ group = "auto_lint" })
check(#lint_autocmds == 1 and lint_autocmds[1].event == "BufWritePost", "Lint 应只在 BufWritePost 触发")

local temp = vim.fn.tempname()
vim.fn.mkdir(temp .. "/repo/.git", "p")
vim.fn.mkdir(temp .. "/repo/src/deep", "p")
vim.fn.writefile({ "return true" }, temp .. "/repo/src/deep/example.lua")
vim.fn.writefile(
    { "root = true", "", "[*.ts]", "indent_style = space", "indent_size = 3" },
    temp .. "/repo/.editorconfig"
)
vim.fn.writefile({ "const value = true" }, temp .. "/repo/example.ts")
vim.fn.mkdir(temp .. "/vault/.obsidian", "p")
vim.fn.mkdir(temp .. "/vault/notes", "p")

local project = require("project")
check(
    project.root_from(temp .. "/repo/src/deep/example.lua") == realpath(temp .. "/repo"),
    "project root 应识别最近的 .git"
)
check(project.root_from(temp .. "/vault/notes") == realpath(temp .. "/vault"), "project root 应识别 .obsidian")

local editorconfig_restore = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(editorconfig_restore)
vim.cmd("edit " .. vim.fn.fnameescape(temp .. "/repo/example.ts"))
local editorconfig_buf = vim.api.nvim_get_current_buf()
check(
    vim.bo[editorconfig_buf].shiftwidth == 3,
    "真实打开文件时，项目 .editorconfig 应覆盖 GeoVim 默认值"
)
vim.api.nvim_buf_delete(editorconfig_buf, { force = true })

local sensitive_restore = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(sensitive_restore)
local sensitive_buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(sensitive_buf)
vim.bo[sensitive_buf].undofile = true
vim.bo[sensitive_buf].swapfile = true
vim.cmd("file " .. vim.fn.fnameescape(temp .. "/repo/config.env"))
check(vim.bo[sensitive_buf].undofile == false, "改名后的环境配置不应启用 persistent undo")
check(vim.bo[sensitive_buf].swapfile == false, "改名后的环境配置不应创建 swap")
vim.api.nvim_set_current_buf(sensitive_restore)
vim.api.nvim_buf_delete(sensitive_buf, { force = true })

local saveas_buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_set_current_buf(saveas_buf)
vim.api.nvim_buf_set_lines(saveas_buf, 0, -1, false, { "TOKEN=test" })
vim.bo[saveas_buf].undofile = true
vim.bo[saveas_buf].swapfile = true
vim.cmd("silent keepalt saveas " .. vim.fn.fnameescape(temp .. "/repo/renamed.env"))
check(vim.bo[saveas_buf].undofile == false, ":saveas 环境配置后不应启用 persistent undo")
check(vim.bo[saveas_buf].swapfile == false, ":saveas 环境配置后不应创建 swap")
vim.api.nvim_set_current_buf(sensitive_restore)
vim.api.nvim_buf_delete(saveas_buf, { force = true })

local backupskip = vim.opt.backupskip:get()
check(vim.list_contains(backupskip, ".env"), "backupskip 应包含 .env")
check(vim.list_contains(backupskip, "*.env"), "backupskip 应包含 config.env 等环境文件")
check(vim.list_contains(backupskip, "*.key"), "backupskip 应包含私钥 pattern")

local sockets = temp .. "/sockets"
vim.fn.mkdir(sockets, "p")
local function add_session(name, info)
    local socket = sockets .. "/" .. name .. ".sock"
    vim.fn.writefile({}, socket)
    vim.fn.writefile({ vim.json.encode(info) }, socket .. ".info")
    return socket
end

local parent_socket = add_session("parent", {
    cwd = temp .. "/repo",
    pid = 101,
    startedAt = "2026-01-01T10:00:00.000Z",
})
add_session("child", {
    cwd = temp .. "/repo",
    pid = 102,
    startedAt = "2026-01-01T10:01:00.000Z",
    isSubagent = false, -- 伪造 metadata 不能覆盖进程祖先检测
})
add_session("unknown", {
    cwd = temp .. "/repo",
    pid = 104,
    startedAt = "2026-01-01T10:01:30.000Z",
})
add_session("spoofed-metadata", {
    cwd = temp .. "/repo",
    pid = 105,
    startedAt = "2026-01-01T10:01:45.000Z",
    isSubagent = false,
})
add_session("stale", {
    cwd = temp .. "/repo",
    pid = 999,
    startedAt = "2026-01-01T10:02:00.000Z",
})

local pi_session = require("pi_session")
check(#pi_session.sessions({
    sockets_dir = sockets,
    process_is_alive = function()
        return true
    end,
    classify_process = function()
        return false
    end,
}) == 0, "Pi discovery 不应把普通文件当成 Unix socket")

local resolve_opts = {
    sockets_dir = sockets,
    target_root = temp .. "/repo",
    process_is_alive = function(pid)
        return pid ~= 999
    end,
    socket_is_valid = function()
        return true
    end,
    classify_process = function(pid)
        if pid == 102 then
            return true
        end
        if pid == 101 or pid == 103 then
            return false
        end
        -- 104 是角色未知的 Pi，105 模拟 metadata 伪装但 PID 不属于 Pi。
        return nil
    end,
}
local resolved = pi_session.resolve(resolve_opts)
check(resolved == parent_socket, "Pi 自动路由应过滤 subagent、未知身份、伪造 metadata 和陈旧 socket")

local second_socket = add_session("second", {
    cwd = temp .. "/repo",
    pid = 103,
    startedAt = "2026-01-01T10:03:00.000Z",
})
local ambiguous, reason = pi_session.resolve(resolve_opts)
check(ambiguous == nil and reason and reason:match("2 个 Pi session"), "多个 Pi session 时必须 fail closed")
resolve_opts.configured = second_socket
check(pi_session.resolve(resolve_opts) == second_socket, "手动选择的 Pi session 应优先使用")

local image_source = table.concat(vim.fn.readfile("lua/plugins/image.lua"), "\n")
check(image_source:match("download_remote_images%s*=%s*true") ~= nil, "远程 Markdown 图片下载必须保持启用")

local marksman_source = table.concat(vim.fn.readfile("lua/plugins/lsp.lua"), "\n")
check(marksman_source:match('"%.obsidian"') ~= nil, "Marksman root markers 应包含 .obsidian")

for name, kind in vim.fs.dir("lua/plugins") do
    if kind == "file" and name:match("%.lua$") then
        local ok, specs = pcall(dofile, "lua/plugins/" .. name)
        check(ok and type(specs) == "table", name .. " 必须返回 lazy.nvim spec table")
        if ok and type(specs) == "table" then
            for index, spec in ipairs(specs) do
                local has_trigger = spec.lazy == false
                    or spec.event ~= nil
                    or spec.cmd ~= nil
                    or spec.keys ~= nil
                    or spec.ft ~= nil
                check(has_trigger, string.format("%s spec #%d 缺少 lazy trigger", name, index))
            end
        end
    end
end

local lazy_config = require("lazy.core.config")
check(lazy_config.options.rocks.enabled == false, "lazy.nvim LuaRocks 管线应关闭")

vim.fn.delete(temp, "rf")

if #failures > 0 then
    for _, failure in ipairs(failures) do
        io.stderr:write("FAIL: " .. failure .. "\n")
    end
    io.stderr:write(string.format("%d/%d smoke checks failed\n", #failures, checks))
    vim.cmd("cquit 1")
else
    print(string.format("Smoke checks passed: %d", checks))
    vim.cmd("qa!")
end

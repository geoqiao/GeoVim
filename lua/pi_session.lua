-- ============================================
-- pi-nvim session 安全解析器
-- ============================================
-- 上游插件在同一 cwd 有多个 socket 时会静默选择最新的一个，这可能把 prompt
-- 发给 subagent。这里采用 fail-closed：只在当前项目恰好有一个可用主候选时
-- 自动连接；有歧义时必须通过 :PiSessions / <leader>pS 明确选择。

local M = {}

local project = require("project")
local sockets_dir = "/tmp/pi-nvim-sockets"
local last_error
local process_role_cache = {}

local function process_is_alive(pid)
    if not pid then
        return false
    end

    local ok, result = pcall(vim.uv.kill, tonumber(pid), 0)
    return ok and result == 0
end

local function socket_is_valid(path)
    local stat = vim.uv.fs_stat(path)
    return stat ~= nil and stat.type == "socket"
end

local function process_row(pid)
    if vim.fn.executable("ps") ~= 1 then
        return nil, nil
    end

    local result = vim.system({ "ps", "-p", tostring(pid), "-o", "ppid=,command=" }, { text = true }):wait()
    if result.code ~= 0 then
        return nil, nil
    end

    local parent_pid, command = result.stdout:match("^%s*(%d+)%s+(.+)%s*$")
    return tonumber(parent_pid), command
end

local function is_pi_command(command)
    local executable = command and command:match("^%s*(%S+)")
    return executable ~= nil and vim.fs.basename(executable) == "pi"
end

--- 通过进程祖先识别本机 Pi 主会话 / subagent。无法确认时返回 nil，自动路由会 fail closed。
---@param pid integer
---@return boolean|nil is_subagent
local function classify_process(pid)
    local cached = process_role_cache[pid]
    local now = vim.uv.now()
    if cached and now - cached.checked_at < 10000 then
        if cached.known then
            return cached.is_subagent
        end
        return nil
    end

    local parent_pid, command = process_row(pid)
    if not parent_pid or not is_pi_command(command) then
        process_role_cache[pid] = { checked_at = now, known = false }
        return nil
    end

    for _ = 1, 8 do
        if parent_pid <= 1 then
            break
        end
        local next_parent, parent_command = process_row(parent_pid)
        if not parent_command then
            break
        end
        if
            is_pi_command(parent_command)
            or parent_command:find("pi%-subagents")
            or parent_command:find("subagent%-runner")
        then
            process_role_cache[pid] = { checked_at = now, known = true, is_subagent = true }
            return true
        end
        parent_pid = next_parent or 0
    end

    process_role_cache[pid] = { checked_at = now, known = true, is_subagent = false }
    return false
end

local function read_info(info_path)
    local ok, lines = pcall(vim.fn.readfile, info_path)
    if not ok or not lines[1] then
        return nil
    end

    local decoded, info = pcall(vim.json.decode, lines[1])
    if not decoded or type(info) ~= "table" then
        return nil
    end

    return info
end

local function classify_session(info, pid, process_classifier)
    -- metadata 只能补充角色，不能替代本机进程身份验证；PID 被非 Pi 进程复用时必须 fail closed。
    local detected = process_classifier(pid)
    if detected == nil then
        return false, false
    end

    if type(info.isSubagent) == "boolean" then
        return detected or info.isSubagent, true
    end
    if info.sessionId and info.parentSessionId then
        return detected or info.sessionId ~= info.parentSessionId, true
    end

    return detected, true
end

---@class PiSessionListOpts
---@field sockets_dir? string
---@field process_is_alive? fun(pid: integer): boolean
---@field socket_is_valid? fun(path: string): boolean
---@field classify_process? fun(pid: integer): boolean|nil

--- 返回 socket / PID 存活的 session，并标记进程身份；身份未知项只允许手动选择。
---@param opts? PiSessionListOpts
---@return table[]
function M.sessions(opts)
    opts = opts or {}
    local dir = opts.sockets_dir or sockets_dir
    local alive = opts.process_is_alive or process_is_alive
    local valid_socket = opts.socket_is_valid or socket_is_valid
    local process_classifier = opts.classify_process or classify_process
    local ok, files = pcall(vim.fn.glob, dir .. "/*.info", false, true)
    if not ok then
        return {}
    end

    local sessions = {}
    for _, info_path in ipairs(files) do
        local info = read_info(info_path)
        local socket = info_path:sub(1, -6)
        local pid = info and tonumber(info.pid) or nil
        if info and pid and valid_socket(socket) and alive(pid) then
            local subagent, role_known = classify_session(info, pid, process_classifier)
            sessions[#sessions + 1] = {
                cwd = info.cwd,
                pid = pid,
                started_at = info.startedAt,
                socket = socket,
                root = project.root_from(info.cwd),
                is_subagent = subagent,
                role_known = role_known,
            }
        end
    end

    table.sort(sessions, function(left, right)
        return (left.started_at or "") < (right.started_at or "")
    end)
    return sessions
end

local function find_socket(sessions, socket)
    for _, session in ipairs(sessions) do
        if session.socket == socket then
            return session
        end
    end
end

---@class PiSessionResolveOpts
---@field configured? string
---@field target_root? string
---@field sockets_dir? string
---@field process_is_alive? fun(pid: integer): boolean
---@field socket_is_valid? fun(path: string): boolean
---@field classify_process? fun(pid: integer): boolean|nil

--- 解析安全目标。手动选择的 session 优先；自动发现从不跨项目 fallback。
---@param opts? PiSessionResolveOpts
---@return string|nil socket
---@return string|nil reason
---@return table|nil session
function M.resolve(opts)
    opts = opts or {}
    local sessions = M.sessions(opts)

    if opts.configured then
        local selected = find_socket(sessions, opts.configured)
        if selected then
            return selected.socket, nil, selected
        end
        return nil, "已选择的 Pi session 已退出，请重新选择", nil
    end

    local target_root = opts.target_root or project.current()
    local candidates = {}
    for _, session in ipairs(sessions) do
        if session.role_known and not session.is_subagent and project.same(session.root, target_root) then
            candidates[#candidates + 1] = session
        end
    end

    if #candidates == 1 then
        return candidates[1].socket, nil, candidates[1]
    end
    if #candidates > 1 then
        return nil,
            string.format("当前项目有 %d 个 Pi session，请先按 <leader>pS 明确选择", #candidates),
            nil
    end
    if #sessions > 0 then
        return nil, "当前项目没有可自动连接的 Pi session，请按 <leader>pS 选择", nil
    end
    return nil, "没有可用的 Pi session，请确认 Pi 正在运行", nil
end

local function format_started_at(value)
    if not value then
        return ""
    end
    local hour, minute = value:match("T(%d+):(%d+):")
    return hour and string.format(" · %s:%s", hour, minute) or ""
end

--- 用安全解析逻辑替换上游的“最新 socket”策略，不修改 lazy.nvim 管理的插件文件。
---@param pi table
function M.setup(pi)
    local original_send_raw = pi.send_raw

    pi.get_socket_path = function()
        local socket, reason = M.resolve({ configured = pi.config.socket_path })
        if not socket and pi.config.socket_path then
            pi.config.socket_path = nil
            socket, reason = M.resolve()
        end
        last_error = reason
        return socket
    end

    pi.send_raw = function(message, callback)
        if not pi.get_socket_path() then
            local err = last_error or "无法确定 Pi session"
            vim.notify("[GeoVim] " .. err, vim.log.levels.ERROR)
            if callback then
                callback(err, nil)
            end
            return
        end
        return original_send_raw(message, callback)
    end

    pi.list_sessions = function()
        local sessions = M.sessions()
        if #sessions == 0 then
            vim.notify("[GeoVim] 没有可用的 Pi session", vim.log.levels.INFO)
            return
        end

        local current = pi.get_socket_path()
        vim.ui.select(sessions, {
            prompt = "Pi sessions:",
            format_item = function(session)
                local marker = current == session.socket and "●" or "○"
                local kind = session.is_subagent and " · subagent"
                    or not session.role_known and " · role unknown"
                    or ""
                return string.format(
                    "%s %s · pid %d%s%s",
                    marker,
                    session.cwd or "?",
                    session.pid,
                    format_started_at(session.started_at),
                    kind
                )
            end,
        }, function(session)
            if not session then
                return
            end
            pi.config.socket_path = session.socket
            last_error = nil
            vim.notify(
                string.format("[GeoVim] 已连接 Pi：%s [pid %d]", session.cwd or "?", session.pid),
                vim.log.levels.INFO
            )
        end)
    end
end

return M

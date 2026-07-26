-- ============================================
-- 项目根目录解析
-- ============================================
-- Telescope、文件树和 Pi 必须对“当前项目”使用同一套判断，避免从 Home
-- 打开绝对路径文件时误把整个 Home 当成搜索范围。

local M = {}

M.root_markers = {
    ".git",
    ".marksman.toml",
    ".obsidian",
    "pyproject.toml",
    "uv.lock",
    "package-lock.json",
    "pnpm-lock.yaml",
    "yarn.lock",
    "bun.lock",
    "bun.lockb",
    "package.json",
    "Cargo.toml",
    "go.mod",
}

local function normalize(path)
    if not path or path == "" then
        return nil
    end

    local absolute = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
    return vim.uv.fs_realpath(absolute) or absolute
end

--- 从文件或目录向上寻找最近的项目标记；没有标记时回退到文件所在目录。
---@param path string
---@return string|nil
function M.root_from(path)
    local normalized = normalize(path)
    if not normalized then
        return nil
    end

    local stat = vim.uv.fs_stat(normalized)
    local start = stat and stat.type == "directory" and normalized or vim.fs.dirname(normalized)
    if not start then
        return nil
    end

    local marker = vim.fs.find(M.root_markers, { path = start, upward = true })[1]
    return normalize(marker and vim.fs.dirname(marker) or start)
end

--- 返回当前普通文件 Buffer 所属项目；特殊 Buffer 回退到进程 cwd。
---@param bufnr? integer
---@return string
function M.current(bufnr)
    bufnr = bufnr or 0
    if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "" then
        local name = vim.api.nvim_buf_get_name(bufnr)
        local root = M.root_from(name)
        if root then
            return root
        end
    end

    return M.root_from(vim.uv.cwd()) or vim.uv.cwd()
end

--- 比较两个路径解析后的真实路径是否相同。
---@param left string|nil
---@param right string|nil
---@return boolean
function M.same(left, right)
    local normalized_left = normalize(left)
    local normalized_right = normalize(right)
    return normalized_left ~= nil and normalized_left == normalized_right
end

return M

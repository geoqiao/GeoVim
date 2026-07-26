-- ============================================
-- 敏感文件保护
-- ============================================
-- 普通代码继续使用 swap、persistent undo 和 writebackup；只有可能包含密钥的
-- 文件禁用持久状态，避免凭据在文件修改或删除后长期留在 Neovim state 目录。

local M = {}

M.patterns = {
    ".env",
    ".env.*",
    "*.env",
    "*.env.*",
    "*.pem",
    "*.key",
    "id_rsa",
    "id_ed25519",
    "id_ecdsa",
    "id_dsa",
}

function M.setup_options()
    -- backupskip 同时作用于 backup 和 writebackup；这是全局 writebackup
    -- 无法按 Buffer 关闭时，Neovim 提供的官方例外机制。
    local current = vim.opt.backupskip:get()
    for _, pattern in ipairs(M.patterns) do
        if not vim.list_contains(current, pattern) then
            vim.opt.backupskip:append(pattern)
        end
    end
end

---@param bufnr integer
function M.protect_buffer(bufnr)
    vim.bo[bufnr].undofile = false
    vim.bo[bufnr].swapfile = false
end

return M

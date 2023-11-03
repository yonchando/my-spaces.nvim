local M = {}
function M.reload()
    require("plenary.reload").reload_module("my_spaces")
end

local log_levels = { "trace", "debug", "info", "warn", "error", "fatal" }
local function set_log_level()
    local log_level = vim.env.HARPOON_LOG or vim.g.harpoon_log_level

    for _, level in pairs(log_levels) do
        if level == log_level then
            return log_level
        end
    end

    return "warn" -- default, if user hasn't set to one from log_levels
end

local log_level = set_log_level()

M.log = require("plenary.log").new({
    plugin = "my-spaces",
    level = log_level,
})

return M

local Path = require("plenary.path")
local log = require("my_spaces.dev").log

local data_path = vim.fn.stdpath("data")
local cache_config = string.format("%s/my-spaces.json", data_path)

local M = {};

M.print = function(value)
    print(vim.inspect(value))
end

-- TODO add working directory to lists
M.add_space = function(path)
    if path == nil then
        path = vim.fn.expand("%:p:h")
    end
    local json = vim.json.encode({ path })
    log.trace("add_space() Saving cache config to", cache_config)
    Path:new(cache_config):write(json, "w")
end

-- TODO lists working directories
M.list_space = function()
    log.trace("_read_config(): ", cache_config)
    local json = vim.json.decode(Path:new(cache_config):read())

    vim.ui.select(json or {}, {
        prompt = "Select a space",
        telescope = require("telescope.themes").get_dropdown()
    }, function(selected)
        M.print(selected)
    end)
end

-- TODO remove working directories
M.remove_space = function()
    print("remove space")
end

M.setup = function()
    vim.api.nvim_create_user_command("AddSpace", function()
        package.loaded.my_spaces = nil
        M.add_space()
    end, {})

    vim.api.nvim_create_user_command("ListSpace", function()
        package.loaded.my_spaces = nil
        M.list_space()
    end, {})
end

return M

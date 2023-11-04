local Path = require("plenary.path")
local config = require("my_spaces.config")
local log = require("my_spaces.dev").log

local data_path = vim.fn.stdpath("data")
local cache_config = string.format("%s/my-spaces.json", data_path)

local M = {};

P = function(value)
    print(vim.inspect(value))
end

local read_file = function(local_config)
    log.trace("_read_config(): ", local_config)
    return vim.json.decode(Path:new(local_config):read())
end

local write_files = function(json)
    log.trace("add_space() Saving cache config to", cache_config)
    Path:new(cache_config):write(vim.json.encode(json), "w")
end

local check_path_exists = function(tab, path)
    for _, value in ipairs(tab) do
        if value.path == path then
            return true
        end

        return false
    end
end

-- TODO add working directory to lists
M.add_space = function(opts)
    local path = vim.trim(opts.path or config.path)

    path, _ = string.gsub(path, "/*$", "")

    if path == nil then
        path = vim.fn.expand("%:p:h")
    end
    local ok, reads = pcall(read_file, cache_config)
    local list = {}

    if ok and reads then
        list = reads

        if check_path_exists(reads, path) then
            print("Path already exists")
            return
        end

        table.insert(list, { index = #reads + 1, path = path })
    else
        list = {
            {
                index = 1,
                path = path
            }
        }
    end

    write_files(list)
    print("Working directory added " .. path)
end

-- TODO lists working directories
M.list_space = function()
    local ok, json = pcall(read_file, cache_config)

    local list = {}

    if ok then
        for _, value in ipairs(json or {}) do
            table.insert(list, value.path)
        end
    end

    vim.ui.select(list, {
        prompt = "Select a space",
        telescope = require("telescope.themes").get_dropdown()
    }, function(selected)
        if selected then
            vim.fn.execute("cd " .. selected, "silent")

            local nvimtree_api_ok, nvimtree_api = pcall(require, "nvim-tree.api")

            if nvimtree_api_ok then
                nvimtree_api.tree.change_root(selected)
                nvimtree_api.tree.reload()
            end

            print("Project root to " .. selected)
        end
    end)
end

-- TODO remove working directories
M.remove_space = function()
    local ok, json = pcall(read_file, cache_config)

    local list = {}

    if ok then
        for _, value in ipairs(json or {}) do
            table.insert(list, value.path)
        end
    end

    vim.ui.select(list, {
        prompt = "Remove List Select a space",
        telescope = require("telescope.themes").get_dropdown()
    }, function(selected)
        if json then
            for i, value in ipairs(json) do
                if value.path == selected then
                    table.remove(json, i)
                end
            end
            write_files(json)
            print(selected .. " removed")
        end
    end)
end

M.clean_spaces = function()
    vim.cmd("!rm -rf " .. cache_config)
end

M.setup = function()
    -- Set user command Add Space
    vim.api.nvim_create_user_command("AddSpace", function(opts)
        if opts.args ~= "" then
            config.path = vim.fn.getcwd() .. "/" .. opts.args
        end

        require("my_spaces").add_space(config)
    end, {
        nargs = '?',
        complete = "dir"
    })

    -- Set user command List Space
    vim.api.nvim_create_user_command("ListSpace", function()
        require("my_spaces").list_space()
    end, {})

    -- Set user command remove space from List Space
    vim.api.nvim_create_user_command("RemoveSpace", function()
        require("my_spaces").remove_space()
    end, {})

    -- Set user command delete data file json
    vim.api.nvim_create_user_command("CleanSpace", function()
        require("my_spaces").clean_spaces()
    end, {})
end

return M

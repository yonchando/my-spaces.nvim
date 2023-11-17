local Path = require("plenary.path")
local config = require("my_spaces.config")
local log = require("my_spaces.dev").log
local ui = require("my_spaces.ui")

local data_path = vim.fn.stdpath("data")
local cache_config = string.format("%s/my-spaces.json", data_path)

local M = {};

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

local get_menus = function()
    local ok, json = pcall(read_file, cache_config)

    local list = {}

    if ok then
        for _, value in ipairs(json or {}) do
            table.insert(list, value.path)
        end
    end

    return {
        list = list,
        json = json
    }
end

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

M.list_space = function(configs)
    local menus = get_menus()
    ui.toggle_menu(menus.list, configs)
end

M.go_to = function(index)
    local menus = get_menus()


    if #menus.list < index then
        print("Index over range")
        vim.cmd("ListSpace")
        return
    end

    local selected = menus.list[index]

    if not vim.loop.fs_stat(selected) then
        print("Project path does not exits")
        return
    end

    vim.fn.execute("cd " .. selected, "silent")

    local nvimtree_api_ok, nvimtree_api = pcall(require, "nvim-tree.api")

    if nvimtree_api_ok then
        nvimtree_api.tree.change_root(selected)
        nvimtree_api.tree.reload()
    end
    print("Project root to " .. selected)
end

M.setup = function(configs)
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
        require("my_spaces").list_space(configs)
    end, {})
end

return M

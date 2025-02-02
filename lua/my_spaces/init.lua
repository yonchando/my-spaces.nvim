local Path = require("plenary.path")
local config = require("my_spaces.config")
local log = require("my_spaces.dev").log
local ui = require("my_spaces.ui")

local data_path = vim.fn.stdpath("data")
local cache_config = string.format("%s/my-spaces.json", data_path)

local M = {};

local read_file = ui.read_file

local write_files = function(json, path)
    log.trace("add_space() Saving cache config to", cache_config)

    if not path then
        path = cache_config
    end

    Path:new(path):write(vim.json.encode(json), "w")
end

local check_path_exists = function(tab, path)
    local isExist = false

    for _, value in ipairs(tab) do
        if value.path == path then
            isExist = true
            break
        end
    end

    return isExist
end

local get_menus = ui.get_menus

M.add_space = function(opts)
    local path = vim.trim(opts.path or config.path)

    path, _ = string.gsub(path, "/*$", "")

    if path == nil then
        path = vim.fn.expand("%:p:h")
    end

    local ok, reads = pcall(read_file, cache_config)

    local list = {}

    local stat = vim.loop.fs_stat(path)

    if stat == nil then
        print("no such file or directory" .. path)
        return
    end


    if ok and reads then
        list = reads

        if check_path_exists(reads, path) then
            if stat.type == "directory" then
                print("Directory already exists")
            end

            if stat.type == "file" then
                print("File already exists")
            end

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

    if stat.type == "directory" then
        print("Directory added " .. path)
    end

    if stat.type == "file" then
        print("File added " .. path)
    end
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

    ui.open(selected)
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
        complete = "file_in_path"
    })

    -- Set user command List Space
    vim.api.nvim_create_user_command("ListSpace", function()
        require("my_spaces").list_space(configs)
    end, {})
end

return M

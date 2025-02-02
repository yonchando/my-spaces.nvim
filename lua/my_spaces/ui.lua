local Path = require("plenary.path")
local log = require("my_spaces.dev").log
local popup = require("plenary.popup")
local config = require("my_spaces.config")

local M = {}

local data_path = vim.fn.stdpath("data")
local cache_config = string.format("%s/my-spaces.json", data_path)

M.read_file = function(local_config)
    log.trace("_read_config(): ", local_config)
    return vim.json.decode(Path:new(local_config):read())
end

M.get_menus = function()
    local ok, json = pcall(M.read_file, cache_config)

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

local write_files = function(json)
    log.trace("add_space() Saving cache config to", cache_config)
    Path:new(cache_config):write(vim.json.encode(json), "w")
end

local function create_window(configs)
    local width = configs.width or config.width
    local height = configs.height or config.height

    local bufnr = vim.api.nvim_create_buf(false, false)
    local win_id, win = popup.create(bufnr, {
        title = "My Spaces",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
    })

    vim.api.nvim_win_set_option(
        win.border.win_id,
        "winhl",
        "Normal:MyProjectSpacesBorder"
    )

    return {
        bufnr = bufnr,
        win_id = win_id
    }
end

local function close_window(win_id)
    if vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
        vim.keymap.del("n", "q")
        vim.keymap.del("n", "<ESC>")
        vim.keymap.del("i", "<C-c>")
        vim.cmd("stopinsert")
    end
end

local bufnr = nil
local win_id = nil

M.toggle_menu = function(content, configs)
    if win_id ~= nil and vim.api.nvim_win_is_valid(win_id) then
        close_window(win_id)
        return
    end

    local win_info = create_window(configs or {})
    win_id = win_info.win_id
    bufnr = win_info.bufnr

    vim.api.nvim_buf_set_name(bufnr, "my-project-spaces-menu")

    vim.api.nvim_win_set_option(win_id, "number", true)
    vim.api.nvim_win_set_option(win_id, "relativenumber", true)
    vim.api.nvim_buf_set_option(bufnr, "filetype", "myspace")
    vim.api.nvim_buf_set_option(bufnr, "buftype", "acwrite")
    vim.api.nvim_buf_set_option(bufnr, "bufhidden", "delete")

    local list = {}

    for _, value in pairs(content) do
        local name = string.gsub(value, vim.fn.getenv("HOME"), "~")
        table.insert(list, name)
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, #list, false, list)

    vim.keymap.set("n", "q", function()
        close_window(win_id)
    end, { silent = true, desc = "Close My Project Spaces" })

    vim.keymap.set("n", "<ESC>", function()
        close_window(win_id)
    end, { silent = true, desc = "Close My Project Spaces" })

    vim.keymap.set("i", "<C-c>", function()
        close_window(win_id)
    end, { silent = true, desc = "Close My Project Spaces" })

    vim.keymap.set("n", "<CR>", function()
        local idx = vim.fn.line(".")

        content = M.get_menus().list

        local selected = content[idx]

        if selected == nil then
            return
        end

        M.open(selected)

        close_window(win_id)
    end)

    vim.cmd(
        string.format("au BufWriteCmd <buffer=%s> lua require('my_spaces.ui').save_menu()", bufnr)
    )
    vim.cmd(
        string.format(
            "au TextChanged,TextChangedI <buffer=%s> lua require('my_spaces.ui').save_menu()",
            bufnr
        )
    )
end

M.open = function(selected)
    local stat = vim.loop.fs_stat(selected)

    if vim.loop.fs_stat(selected) == nil then
        print("no such file or directory " .. selected)

        if win_id ~= nil then
            close_window(win_id)
        end
        return
    end

    if stat.type == "directory" then
        vim.fn.execute("cd " .. selected, "silent")

        local nvimtree_api_ok, nvimtree_api = pcall(require, "nvim-tree.api")

        if nvimtree_api_ok then
            nvimtree_api.tree.change_root(selected)
            nvimtree_api.tree.reload()
        end
        print("Project root to " .. selected)
    end
    --
    if stat.type == "file" then
        vim.cmd("tabnew " .. selected)
    end
end

M.save_menu = function()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local lists = {}

    for index, line in ipairs(lines) do
        if line ~= "" then
            local name = string.gsub(line, "~", vim.fn.getenv("HOME"))
            table.insert(lists, { index = index, path = name })
        end
    end

    write_files(lists)
end

return M

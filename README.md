# My spaces

My spaces for easy to change project root.

### Installtion

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
    use {
       'yonchando/my-spaces.nvim',
       requires = {
         'nvim-telescope/telescope.nvim',
         'nvim-lua/plenary.nvim'
       },
       config = function()
         require("my_spaces").setup()
       end
    }
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
  use {
      'yonchando/my-spaces.nvim',
      requires = {
        'nvim-telescope/telescope.nvim',
        'nvim-lua/plenary.nvim'
      },
      config = function()
        require("my_spaces").setup()
      end
  }
```

## Configs

|Property|Type   |Default|Description              |
|--------|-------|-----  |-------------------------|
|width   |number |120    |Width the windows popup  |
|height  |number |30     |Height the windows popup |

## Usage

Open the window lists buffer by `:ListSpace`

In list buffer you can use the buffer like normal file like `hjkl` to move or insert by `i`. Every project with separate by new line.

> Note: Seperate projects by line

|Key |Mode|Description |
|----|----|------------|
|q   |n   |Close       |
|Esc |n   |Close       |
|C-c |i   |Close       |

### Using with vim cmd
```lua
:AddSpace your-space-path
```
### Using [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)
```lua
local nvimtree = require('nvim-tree')

nvimtree.setup({
  on_attach = function(bufnr)
        vim.keymap.set("n", "M", function()
            local node = api.tree.get_node_under_cursor()
    
            local ok, my_spaces = pcall(require, "my_spaces")
    
            if ok then
                my_spaces.add_space({ path = node.absolute_path })
            end
        end, opts("Add to my space"))
  end
})
```

## Keymaping
```lua

local my_spaces = pcall(require, "my_spaces")

vim.keymap.set("n", "<leader>ml", vim.cmd.ListSpace, { desc = "[M]y workpaces [L]ist" }) -- List all workspace
vim.keymap.set("n", "<leader>m1", function() my_spaces.go_to(1) end,{desc = "Go to project 1"}) -- Go to project by index start with index 1
vim.keyma1.set("n", "<leader>m2", function() my_spaces.go_to(2) end,{desc = "Go to project 2"})
-- so on

```

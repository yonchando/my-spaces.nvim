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

## Usage

Using with vim cmd
```lua
:AddSpace your-space-path
```
Using [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)
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

Keymaping
```lua
vim.keymap.set("n", "<leader>ml", vim.cmd.ListSpace, { desc = "[M]y workpaces [L]ist" }) -- List all workspace
vim.keymap.set("n", "<leader>mr", vim.cmd.RemoveSpace, { desc = "[M]y workpaces [R]emove List" }) -- List to remove workspace
```

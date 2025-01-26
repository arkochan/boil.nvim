# boil.nvim

A Neovim plugin to generate files with predefined templates in specified directories.

## Installation

Using `lazy.nvim`:

```lua
{
  "arkochan/boil.nvim",
  config = function()
    require("boil").setup({
      file_types = {
        tsx = {
          templates = {
            {
              execute = "component",
              path = "src/components/[FILE_NAME]",
              snippet = "import x from y\nexport default function [FILE_NAME]() {};"
            },
            {
              execute = "dict",
              path = "src/data/[FILE_NAME]",
              snippet = "export default const [FILE_NAME] = {};"
            }
          }
        },
        go = {
          templates = {
            {
              execute = "function",
              path = "src/go/[FILE_NAME]",
              snippet = "func [FILE_NAME]() {\n    // Function implementation\n}"
            },
            {
              execute = "struct",
              path = "src/go/[FILE_NAME]",
              snippet = "type [FILE_NAME] struct {\n    // Struct fields\n}"
            }
          }
        }
      },
      default_extension = "tsx",
      default_template = "component"
    })
  end
}

## Usage 
Run the `:Boil` command with the template name and file name:
```vim
:Boil component NavBar
```

# boil.nvim 

#### ⚡ Boilerplate files Blazingly fast ⚡

A Neovim plugin to generate boilerplate files with predefined templates in specified directories.

## Installation

Using `lazy.nvim`:

```lua
return {
  "arkochan/boil.nvim", -- Path to your local plugin
  config = function()
    require("boil").setup({
      file_types = {
        {
          extensions = { "tsx", "ts" }, -- TypeScript extensions
          default_template = "component",
          functions = {
            {
              keyword = "REACT_IMPORT",
              execute = function()
                return "import React from 'react';"
              end,
            },
            {
              keyword = "FILE_NAME", -- Default function for file name
              execute = function(file_name)
                return file_name
              end,
            },
          },
          templates = {
            {
              trigger = "component",
              path = function(current_file_path)
                -- Example: Place the component in a subdirectory based on the current file's directory
                local dir = vim.fn.fnamemodify(current_file_path, ":h") .. "/components"
                return dir .. "/[FILE_NAME].tsx"
              end,
              filename = function(name, extension)
                -- Example: Convert the name to PascalCase
                return name:gsub("(%l)(%w*)", function(first, rest)
                  return first:upper() .. rest
                end)
              end,
              snippet = "[REACT_IMPORT]\n\nexport default function [FILE_NAME]() {\n  return <div>[FILE_NAME]</div>;\n}",
            },
            {
              trigger = "dict",
              path = "src/data/[FILE_NAME].ts", -- Explicit path as a string
              snippet = "export default const [FILE_NAME] = {};",
            },
          },
        },
        {
          extensions = { "go" }, -- Go extension
          default_template = "function",
          functions = {
            {
              keyword = "GO_PACKAGE_NAME",
              execute = function()
                return vim.fn.input("Enter Go package name: ")
              end,
            },
            {
              keyword = "FILE_NAME", -- Default function for file name
              execute = function(file_name)
                return file_name
              end,
            },
          },
          templates = {
            {
              trigger = "function",
              path = function(current_file_path)
                -- Example: Place the file in a subdirectory based on the current file's directory
                local dir = vim.fn.fnamemodify(current_file_path, ":h") .. "/functions"
                return dir .. "/[FILE_NAME].go"
              end,
              filename = function(name, extension)
                -- Example: Convert the name to snake_case
                return name:gsub("%s+", "_"):lower()
              end,
              snippet = "[GO_PACKAGE_NAME]\n\nfunc [FILE_NAME]() {\n    // Function implementation\n}",
            },
            {
              trigger = "struct",
              path = "src/go/[FILE_NAME].go", -- Explicit path as a string
              snippet = "[GO_PACKAGE_NAME]\n\ntype [FILE_NAME] struct {\n    // Struct fields\n}",
            },
          },
        },
      },
    })
  end,
  -- Requires folke/snacks.nvim for prompt ui
  keys = {
    {
      "<leader>bb",
      function()
        require("boil").create_boilerplate()
      end,
      desc = "Create boilerplate file",
    },
  },
  -- cmd works fine
  cmd = { "Boil" },
}
```

## Usage 
Run the `:Boil <template> <filename>` command with the template name and file name:
```vim
:Boil component NavBar
```
Or, for the default template, Just run `:Boil <filename>`
```vim
:Boil NavBar
```

Or using [folke/snacks.nvim](https://github.com/folke/snacks.nvim)
```lua
keys = {
    {
      "<leader>bb",
      function()
        require("boil").create_boilerplate()
      end,
      desc = "Create boilerplate file",
    },
  },
```

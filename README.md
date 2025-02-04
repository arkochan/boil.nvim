# boil.nvim 

#### ⚡ Boilerplate files Blazingly fast ⚡

A Neovim plugin to generate boilerplate files with predefined templates in specified directories.

## Installation

Using `lazy.nvim`:

```lua
return {
  "arkochan/boil.nvim",
  opts = {
    file_types = {
      {
        extensions = { "tsx", "ts" }, -- TypeScript extensions
        default_template = "component", -- If template arg not provided this is considered by default
        functions = { -- The string substituition function to replace [KEYWORD]s
          {
            keyword = "REACT_IMPORT", -- When found [REACT_IMPORT]
            execute = function(args)
              print("args", args)
              -- The fn argument should rather be given in a table as substitute function arguments
              -- user would use necessary args
              -- this would be called after path has been calculated
              -- :Boil file_name_arg
              return "import React from 'react';\nimport {cn} from '@/lib/utils/cn';"
            end,
          },
          {
            keyword = "COMPONENT_NAME", -- When found [COMPONENT_NAME]

            -- placeholder_fn_arg = {
            -- 	file_name = name,
            -- 	file_path = path,
            -- 	last_active_buffer_path = current_file_path,
            -- 	file_extension = file_ext,
            execute = function(args)
              -- vim.notify(args.file_name_arg)
              -- vim.notify(args)
              local file_name_arg_first_char_capitalized = args.file_name:gsub("^.", string.upper)
              return file_name_arg_first_char_capitalized
            end,
          },
        },
        templates = { -- The actual templates
          {
            trigger = "component", -- First optional arg,  When :Boil component ... This template is triggered
            path = "src/components/",
            -- function(current_file_path) -- To determine the file path this fn is called with last active buffer's file path
            -- -- path can also be a string literal
            --
            -- -- Example: Place the component in a subdirectory based on the current file's directory
            -- -- local dir = vim.fn.fnamemodify(current_file_path, ":h") .. "/components"
            -- return "src/components/"
            -- end,
            filename = function(name, extension) -- What is set as the filename while creating the file
              -- extension is the last active buffer's extension
              -- if nothing is assigned name .. extension is assigned by default
              --
              -- Example: Convert the name to PascalCase
              return name:gsub("(%l)(%w*)", function(first, rest)
                return first:upper() .. rest .. "." .. extension
              end)
            end,
            snippet = '[REACT_IMPORT]\n\nexport default function [COMPONENT_NAME]({className}:{className?:string}) {\n  return (<div className = {cn("",className)} >[COMPONENT_NAME]</div>);\n}',
          },
          {
            trigger = "dict",
            path = "src/data/", -- Explicit path as a string
            filename = function(file_base_name, file_extension)
              return file_base_name .. ".ts" -- To have constant extension
            end,
            snippet = "export default const [COMPONENT_NAME] = {};",
          },
        },
      },
      {
        extensions = { "go" }, -- Go extension
        default_template = "function",
        functions = {
          {
            keyword = "GO_PACKAGE_NAME",
            execute = function(args)
              -- Get the current buffer's lines
              local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

              -- Track whether we're inside a multiline comment block
              local inside_multiline_comment = false

              -- Iterate through the lines to find the package declaration
              for _, line in ipairs(lines) do
                -- Trim leading whitespace
                local trimmed_line = line:match("^%s*(.*)")

                -- Check if we're inside a multiline comment block
                if inside_multiline_comment then
                  -- Check if the line contains the end of the multiline comment
                  if trimmed_line:match(".*%*/") then
                    inside_multiline_comment = false
                  end
                  -- Skip this line since it's inside a comment block
                  goto continue
                end

                -- Check if the line starts a multiline comment
                if trimmed_line:match("^/%*") then
                  inside_multiline_comment = true
                  -- Check if the line also ends the multiline comment
                  if trimmed_line:match(".*%*/") then
                    inside_multiline_comment = false
                  end
                  -- Skip this line since it's a comment
                  goto continue
                end

                -- Skip lines that are single-line comments or empty
                if not trimmed_line:match("^//") and trimmed_line ~= "" then
                  -- Match lines that start with 'package'
                  if trimmed_line:match("^package%s+") then
                    -- Extract the package name
                    local package_name = trimmed_line:match("^package%s+(%S+)")
                    return package_name
                  end
                end

                -- Label to skip to the next iteration
                ::continue::
              end

              -- Return nil if no package declaration is found
              return nil
            end,
          },
          {
            keyword = "FILE_NAME", -- Default function for file name
            execute = function(args)
              return args.file_name .. ".go"
            end,
          },
        },
        templates = {
          {
            trigger = "function",
            path = function(current_file_path)
              -- Example: Place the file in a subdirectory based on the current file's directory
              local dir = vim.fn.fnamemodify(current_file_path, ":h") .. "/functions"
              return dir
            end,
            -- filename = function(name, extension)  -- This will generate default outcome
            --   return name .. extension
            -- end,
            snippet = "[GO_PACKAGE_NAME]\n\nfunc [FILE_NAME]() {\n    // Function implementation\n}",
          },
          {
            trigger = "struct",
            -- here file namw would be considered name_arg.go // as go would be detected at last
            -- name_arg ->    :Boil <template_name> <name_arg>
            -- name_arg can be cosidered as basea file name
            path = "src/go/",
            snippet = "[GO_PACKAGE_NAME]\n\ntype [FILE_NAME] struct {\n    // Struct fields\n}",
          },
        },
      },
    },
  },
  keys = {
    {
      "<leader>bb",
      function()
        require("boil").create_boilerplate()
      end,
      desc = "Create boilerplate file",
    },
  },
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
### Multiple files 
```vim
:Boil {Hero,NavBar,Footer,Main}
```
```

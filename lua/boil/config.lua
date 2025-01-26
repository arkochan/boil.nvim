-- lua/boil/config.lua
local M = {}

M.defaults = {
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
					path = "src/components/[FILE_NAME].tsx", -- Explicit extension
					snippet = "[REACT_IMPORT]\n\nexport default function [FILE_NAME]() {\n  return <div>[FILE_NAME]</div>;\n}",
				},
				{
					trigger = "dict",
					path = "src/data/[FILE_NAME].ts", -- Explicit extension
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
					path = "src/go/[FILE_NAME].go", -- Explicit extension
					snippet = "[GO_PACKAGE_NAME]\n\nfunc [FILE_NAME]() {\n    // Function implementation\n}",
				},
				{
					trigger = "struct",
					path = "src/go/[FILE_NAME].go", -- Explicit extension
					snippet = "[GO_PACKAGE_NAME]\n\ntype [FILE_NAME] struct {\n    // Struct fields\n}",
				},
			},
		},
	},
}

return M

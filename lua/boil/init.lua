-- lua/boil/init.lua
local core = require("boil.core")

local M = {}

function M.setup(user_config)
	-- Merge user config with defaults
	M.config = user_config
end

-- Function to extract template name and file name from user input
local function extract_handler(input, is_interactive)
	-- Ensure setup has been called
	if not M.config then
		vim.notify(
			"Error: boil.nvim has not been configured. Please call require('boil').setup() first.",
			vim.log.levels.ERROR
		)
		return
	end

	if not input or input == "" then
		vim.notify("Error: Input is required.", vim.log.levels.ERROR)
		return
	end

	-- Split input into template name and file name
	local args = vim.split(input, " ")
	local template_name = args[1]
	local file_name = args[2]

	-- If only one argument is provided, treat it as the file name and use the default template
	if not file_name then
		file_name = template_name
		template_name = nil
	end

	-- Infer file type from argument
	local file_type = file_name:match("%.(%w+)$")
	if not file_type then
		-- Infer file type from the last active buffer
		local buf_name = vim.api.nvim_buf_get_name(0)
		file_type = buf_name:match("%.(%w+)$")
		if not file_type then
			vim.notify("Error: Could not infer file type.", vim.log.levels.ERROR)
			return
		end
	else
		-- Remove file extension from file name
		file_name = file_name:gsub("%." .. file_type .. "$", "")
	end

	-- Use default template if not provided
	if not template_name then
		for _, ft in ipairs(M.config.file_types) do
			for _, ext in ipairs(ft.extensions) do
				if file_type == ext then
					template_name = ft.default_template
					break
				end
			end
			if template_name then
				break
			end
		end

		if not template_name then
			vim.notify("Error: No default template found for file type '" .. file_type .. "'.", vim.log.levels.ERROR)
			return
		end
	end

	-- Generate the file(s)
	--
	core.generate_file(file_name, file_type, template_name, M.config)
end

-- Function to create a boilerplate interactively
M.create_boilerplate = function()
	-- Ensure setup has been called
	if not M.config then
		vim.notify(
			"Error: boil.nvim has not been configured. Please call require('boil').setup() first.",
			vim.log.levels.ERROR
		)
		return
	end

	local input_opts = {
		prompt = "Enter template name and file name: ",
		completion = "", -- Optional: Add completion for template names
		default = "", -- Optional: Add a default value
	}

	vim.ui.input(input_opts, function(input)
		extract_handler(input, true)
	end)
end

-- Expose a command
vim.api.nvim_create_user_command("Boil", function(opts)
	-- Ensure setup has been called
	if not M.config then
		vim.notify(
			"Error: boil.nvim has not been configured. Please call require('boil').setup() first.",
			vim.log.levels.ERROR
		)
		return
	end

	local args = vim.split(opts.args, " ")
	local template_name = args[1]
	local file_name = args[2]

	-- If no arguments are provided, use the interactive prompt
	if not template_name and not file_name then
		M.create_boilerplate()
		return
	end

	-- Pass arguments to the extract handler
	extract_handler(opts.args, false)
end, {
	nargs = "*", -- Accepts 0 or more arguments
	complete = function() -- Optional: Add autocompletion for template names
		return { "function", "struct" }
	end,
})

return M

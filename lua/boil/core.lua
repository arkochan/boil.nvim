-- lua/boil/core.lua
local utils = require("boil.utils")
local M = {}

function M.generate_file(file_name_base, file_ext, template_trigger, config)
	-- Expand braces in the file name
	local file_names = utils.expand_braces(file_name_base)

	-- Get the current file path (for dynamic path computation)
	local current_file_path = vim.api.nvim_buf_get_name(0)

	-- Generate files for each expanded file name
	for _, name in ipairs(file_names) do
		-- Validate file type
		local file_type_config
		for _, ft in ipairs(config.file_types) do
			for _, ext in ipairs(ft.extensions) do
				if file_ext == ext then
					file_type_config = ft
					break
				end
			end
			if file_type_config then
				break
			end
		end

		if not file_type_config then
			vim.notify("Error: File type '" .. file_ext .. "' is not configured.", vim.log.levels.ERROR)
			return
		end

		-- Find the template
		local template
		for _, t in ipairs(file_type_config.templates) do
			if t.trigger == template_trigger then
				template = t
				break
			end
		end

		-- Validate template
		if not template then
			vim.notify(
				"Error: Template '" .. template_trigger .. "' not found for file type '" .. file_ext .. "'.",
				vim.log.levels.ERROR
			)
			return
		end

		-- Compute the path
		local path = template.path
		if not path then
			vim.notify("Error: No path found for template '" .. template_trigger .. "'.", vim.log.levels.ERROR)
		end
		if type(template.path) == "function" then
			local success, result = pcall(template.path, current_file_path)
			if success then
				path = result
			else
				vim.notify(
					"Error: Failed to execute path function for template '" .. template_trigger .. "'.",
					vim.log.levels.ERROR
				)
				return
			end
		else
			path = template.path
		end

		-- if type(path) == "function" then
		-- 	path = path(current_file_path)
		-- end

		-- Compute the filename that'd be used to save the file
		local filename = name .. "." .. file_ext
		-- notify name and filename as logs
		-- check if exists and then if functions or just assign the filename
		if template.filename then
			if type(template.filename) == "function" then
				local success, result = pcall(template.filename, name, file_ext)
				if success then
					filename = result
				else
					vim.notify(
						"Error: Failed to execute filename function for template '" .. template_trigger .. "'.",
						vim.log.levels.ERROR
					)
					return
				end
			else
				filename = template.filename
			end
		end

		-- Replace [FILE_NAME] in the path and snippet
		-- path = utils.replace(path, "[FILE_NAME]", filename)

		-- Get the snippet
		local snippet = template.snippet

		-- Replace placeholders using custom functions
		for _, func in ipairs(file_type_config.functions) do
			local placeholder = "[" .. func.keyword .. "]"
			if snippet:find(placeholder) then
				local success, result = pcall(func.execute, filename)
				if not success then
					vim.notify(
						"Error: Failed to execute function for placeholder '" .. placeholder .. "'.",
						vim.log.levels.ERROR
					)
					return
				end
				-- Replace all instances of the placeholder in the snippet with the result
				snippet = utils.replace(snippet, placeholder, result)
			end
		end

		-- Replace [FILE_NAME] in the snippet
		-- snippet = utils.replace(snippet, "[FILE_NAME]", filename)

		-- Create directories if they don't exist

		local dir = vim.fn.fnamemodify(path, ":h")
		vim.fn.mkdir(dir, "p")

		local file_path = vim.fn.fnamemodify(dir .. "/" .. filename, ":p")
		-- log the file path
		-- dir =
		-- filename =

		-- Write the snippet to the file
		local file = io.open(file_path, "w")
		if file then
			file:write(snippet)
			file:close()
			vim.notify("File created: " .. path, vim.log.levels.INFO)
		else
			vim.notify("Error: Could not create file at " .. path, vim.log.levels.ERROR)
		end
	end
end

return M

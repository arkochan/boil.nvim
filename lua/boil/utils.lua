local M = {}

-- Expand braces in a string (e.g., "{Nav,Hero,Temple}" → {"Nav", "Hero", "Temple"})
function M.expand_braces(input)
	local result = {}
	local pattern = "{(.-)}"
	local prefix, list, suffix = input:match("^(.-)" .. pattern .. "(.-)$")

	if not list then
		return { input } -- No braces found, return the input as a single item
	end

	for item in list:gmatch("[^,]+") do
		table.insert(result, prefix .. item .. suffix)
	end

	return result
end

-- Plain replacement (all characters are non-magic)
function M.replace(str, substring, replacement)
	-- Escape special characters in the substring and replacement
	local escaped_substring = substring:gsub("%p", "%%%0")
	local escaped_replacement = replacement:gsub("%%", "%%%%")

	-- Perform the replacement (all occurrences)
	return (str:gsub(escaped_substring, escaped_replacement))
end

return M

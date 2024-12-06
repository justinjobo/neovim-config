local M = {}

M.create_note = function()
	vim.ui.input({ prompt = "Enter your note content: " }, function(input)
		if not input or input == "" then
			return
		end

		local prompt = [[
Given the following note text:
"]] .. input:gsub('"', '\\"') .. [["
Suggest a short descriptive filename (one or two words) that best represents the content.
No spaces, special characters, or file extensions. Just a simple filename.
]]
		local cmd = "echo '" .. prompt:gsub("'", "'\\''") .. "' | sgpt"
		local handle = io.popen(cmd)
		local filename = handle:read("*a")
		handle:close()

		filename = filename:gsub("%s+", "")
		if filename == "" then
			filename = "untitled"
		end

		local local_dir = "/home/jthompson/gdrive/obsidian/Impulse/Jots/"
		local filepath = local_dir .. filename .. ".md"

		-- Write the note locally
		local file = io.open(filepath, "w")
		if file then
			file:write("# " .. filename .. "\n\n")
			file:write(input .. "\n")
			file:close()

			vim.notify("Note saved to: " .. filepath, vim.log.levels.INFO)

			-- Rclone command in quiet mode, no verbose output, all output to /dev/null
			local remote_path = "gdrive:obsidian/Impulse/Jots"
			local rclone_cmd = "rclone copy '"
				.. filepath
				.. "' '"
				.. remote_path
				.. "' --update --ignore-existing --quiet > /dev/null 2>&1"

			-- Execute the command
			local result = os.execute(rclone_cmd)
			if result == true or result == 0 then
				vim.notify("File successfully uploaded to Google Drive!", vim.log.levels.INFO)
			else
				vim.notify("Failed to upload file to Google Drive.", vim.log.levels.ERROR)
			end
		else
			vim.notify("Error: Unable to write to file: " .. filepath, vim.log.levels.ERROR)
		end
	end)
end

return M

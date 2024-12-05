-- local function browser_search()
-- 	print("Hello from browser_search")
-- 	-- local buf = vim.api.nvim_create_buf(false, true)
-- 	-- local config = { relative = "win", row = 3, col = 3, width = 12, height = 3 }
-- 	-- vim.api.nvim_open_win(buf, true, config)
-- end
--
-- return { browser_search = browser_search }
-- -- end
local M = {}
local function setup_terminal_mappings(bufnr)
	-- Switch to normal mode
	vim.api.nvim_buf_set_keymap(bufnr, "t", "<C-n>", "<C-\\><C-n>", { noremap = true, silent = true })
	-- Start visual mode
	vim.api.nvim_buf_set_keymap(bufnr, "n", "v", "v", { noremap = true, silent = true })
	-- Yank selected text
	vim.api.nvim_buf_set_keymap(bufnr, "v", "y", "y", { noremap = true, silent = true })

	vim.api.nvim_set_keymap("n", "<leader>h", ":hide<CR>", { noremap = true, silent = true })
end
function M.on_terminal_exit()
	print("The terminal has been closed. Running exit hook...")
	vim.api.nvim_del_buf(M.already_existing_buf)
	M.already_existing_buf = nil
end
function M.browser_search()
	local is_new_search = true

	if M.already_existing_buf == nil or (type(M.already_existing_buf) ~= "number") then
		print("New search")
		is_new_search = true
	elseif type(M.already_existing_buf) == "number" then
		print("Not new search, type is ", type(M.already_existing_buf))
		print("Checking if existing buffer is valid", M.already_existing_buf)
		is_new_search = not vim.api.nvim_buf_is_valid(M.already_existing_buf)
		-- is_new_search = false
		print("Is valid: ", is_new_search)
	end
	-- Create a new buffer for the floating window

	local float_buf
	if is_new_search then
		print("Creating new buffer, existing one is ", M.already_existing_buf)
		float_buf = vim.api.nvim_create_buf(false, true)
	else
		print("Existing buffer is ", M.already_existing_buf)
		float_buf = M.already_existing_buf
	end
	-- Set up an autocommand to run the exit hook when the buffer is deleted
	vim.api.nvim_create_autocmd("BufDelete", {
		buffer = float_buf,
		callback = M.on_terminal_exit,
	})
	-- Get the current window and buffer
	local current_win = vim.api.nvim_get_current_win()
	local current_buf = vim.api.nvim_get_current_buf()

	-- Set the dimensions of the floating window
	local width = math.floor((vim.api.nvim_win_get_width(current_win) or 80) * 0.90)
	local height = math.floor((vim.api.nvim_win_get_height(current_win) or 24) * 0.90)
	-- Define the floating window options
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		style = "minimal",
		border = "rounded",
	}

	-- Set the buffer to be a terminal
	-- vim.api.nvim_buf_set_option(float_buf, "buftype", "terminal")
	-- vim.api.nvim_buf_set_option(float_buf, "bufhidden", "wipe")

	if is_new_search then
		local search_term = vim.fn.input("Search term: ")
		local url = "duckduckgo.com/'" .. search_term .. "'"
		-- Create the floating window
		local float_win = vim.api.nvim_open_win(float_buf, true, opts)
		vim.bo[float_buf].buftype = "nofile" -- No file type
		vim.bo[float_buf].bufhidden = "wipe" -- Wipe buffer when hidden
		vim.bo[float_buf].swapfile = false -- No swap file
		vim.bo[float_buf].modifiable = true -- Make buffer modifiable
		vim.bo[float_buf].filetype = "floating" -- Set a custom filetype if needed
		-- Focus the floating window
		vim.api.nvim_set_current_win(float_win)

		-- Run elinks in the terminal with the provided URL
		vim.fn.termopen("elinks " .. url)
	else
		print("Already existing buffer: ", M.already_existing_buf)
		print("Current buffer: ", float_buf)
		-- Create the floating window
		local float_win = vim.api.nvim_open_win(float_buf, true, opts)

		-- Focus the floating window
		vim.api.nvim_set_current_win(float_win)
	end
	vim.api.nvim_buf_set_keymap(float_buf, "n", "<leader>wq", "<cmd>bdelete!<CR>", { noremap = true, silent = true })
	setup_terminal_mappings(float_buf)
	vim.api.nvim_create_autocmd("BufDelete", {
		pattern = "*",
		callback = function(event)
			print("Buffer deleted", event.buf)
			if event.buf == M.already_existing_buf then
				print("Setting already_existing_buf to nil")
				M.already_existing_buf = nil
			end
		end,
	})
	M.already_existing_buf = float_buf
end

return M

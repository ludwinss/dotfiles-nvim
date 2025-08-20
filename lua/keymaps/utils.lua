local M = {}

function M.save_file()
	if vim.api.nvim_buf_get_option(0, "readonly") then
		return
	end
	local buftype = vim.api.nvim_buf_get_option(0, "buftype")
	if buftype == "nofile" or buftype == "prompt" then
		return
	end
	if vim.api.nvim_buf_get_option(0, "modifiable") then
		vim.cmd("w!")
	end
end

M.DAP_UI_ENABLED = false
function M.dap_toggle_ui()
	require("plugins.ui.dapui-nvim").toggle()
	M.DAP_UI_ENABLED = not M.DAP_UI_ENABLED
end

function M.dap_float_scope()
	if not M.DAP_UI_ENABLED then
		return
	end
	require("plugins.ui.dapui-nvim").float_element("scopes")
end

function M.toggle_diffview()
	local view = require("diffview.lib").get_current_view()
	if view then
		vim.cmd("DiffviewClose")
	else
		vim.cmd("DiffviewOpen")
	end
end

function M.delete_buffer()
	vim.cmd([[:bp | bdelete #]])
end

function M.toggle_oil()
	local U = require("utils.nvim")

	if U.current_buffer_filetype() == "oil" then
		local win_id = vim.api.nvim_get_current_win()
		vim.api.nvim_win_close(win_id, true)
	else
		local ok, actions = pcall(require, "telescope.actions")
		if ok then
			pcall(actions.close)
		end
		vim.cmd("Oil --float")
	end
end

function M.toggle_completion()
	local ok, codeium = pcall(require, "codeium")
	if ok and codeium.toggle then
		codeium.toggle()
	end
end

function M.close_all_oil_windows()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.api.nvim_buf_get_option(buf, "filetype") == "oil" then
			vim.api.nvim_win_close(win, true)
		end
	end
end

function M.toggle_term(term)
	local opts = { buffer = term.bufnr, noremap = true, silent = true, nowait = true }

	vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
	vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>:bd!<CR>]], opts)
	vim.keymap.set("n", "<Esc><Esc>", "<cmd>bd!<CR>", opts)
end

return M

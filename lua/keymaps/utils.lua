local M = {}
local U = require("utils")

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
	U.refresh_statusline()
end

function M.is_dap_ui_enabled()
	return M.DAP_UI_ENABLED
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

function M.select_current_function()
	local ok, ts_select = pcall(require, "nvim-treesitter.textobjects.select")
	if not ok then
		vim.notify("nvim-treesitter-textobjects no está disponible", vim.log.levels.WARN)
		return
	end
	ts_select.select_textobject("@function.outer")
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

local function is_summary_open()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.api.nvim_get_option_value("filetype", { buf = buf }) == "neotest-summary" then
			return true
		end
	end
	return false
end

local function is_overseer_open()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
		local name = vim.api.nvim_buf_get_name(buf)
		if filetype == "OverseerList" or filetype == "overseer" or name:match("overseer://") then
			return true
		end
	end
	return false
end

function M.toggle_test_views(neotest)
	local overseer_ok, overseer = pcall(require, "overseer")
	if not overseer_ok then
		vim.notify("overseer no está instalado o no se pudo cargar", vim.log.levels.WARN)
	end

	local summary_open = is_summary_open()
	local overseer_open = overseer_ok and is_overseer_open()

	if summary_open or overseer_open then
		if summary_open then
			neotest.summary.close()
		end
		if overseer_ok and overseer_open then
			overseer.close()
		end
		return
	end

	neotest.summary.open()
	if overseer_ok then
		overseer.open()
	end
end

function M.toggle_neogit()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.bo[buf].filetype
		if ft == "NeogitStatus" or ft == "NeogitLogView" or ft == "NeogitCommitView" then
			pcall(vim.api.nvim_win_close, win, true)
			return
		end
	end

	pcall(vim.cmd, "Neogit")
end

function M.goto_function(direction)
	local ok, move = pcall(require, "nvim-treesitter.textobjects.move")
	if not ok then
		vim.notify("nvim-treesitter-textobjects no está disponible", vim.log.levels.WARN)
		return
	end

	if direction == "next" then
		move.goto_next_start("@function.outer")
	elseif direction == "prev" then
		move.goto_previous_start("@function.outer")
	end
end

return M

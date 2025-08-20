local M = {}

local U = require("utils")

-- TODO: This is a bit of a hack, but it works for now.
-- vim.hl.priorities.semantic_tokens = 99

local signs = {
	text = {
		[vim.diagnostic.severity.ERROR] = "",
		[vim.diagnostic.severity.WARN] = "",
		[vim.diagnostic.severity.INFO] = "",
		[vim.diagnostic.severity.HINT] = "",
	},
	numhl = {
		[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
		[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
		[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
		[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
	},
}

M.virtual_diagnostics = true
function M.toggle_virtual_diagnostics()
	M.virtual_diagnostics = not M.virtual_diagnostics
	vim.diagnostic.config({
		signs = signs,
		virtual_lines = M.virtual_diagnostics,
		virtual_text = false,
		update_in_insert = true,
		severity_sort = true,
	})
	U.merge_highlights_table({
		DiagnosticUnderlineError = { underline = not M.virtual_diagnostics },
		DiagnosticUnderlineWarn = { underline = not M.virtual_diagnostics },
		DiagnosticUnderlineHint = { underline = not M.virtual_diagnostics },
		DiagnosticUnderlineOk = { underline = not M.virtual_diagnostics },
		DiagnosticUnderlineInfo = { underline = not M.virtual_diagnostics },
	})
	require("utils").refresh_statusline()
end

M.toggle_virtual_diagnostics()

-- TODO: For some reason this is still required for telescope stuff.
vim.fn.sign_define("DiagnosticSignError", { text = "", numhl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", numhl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", numhl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", numhl = "DiagnosticSignHint" })

local float_options = {
	border = U.border_chars_round,
	prefix = "  ",
	header = "",
	severity_sort = true,
}

function M.open_diagnostics_float()
	vim.diagnostic.open_float(float_options)
end

function M.next_error()
	vim.diagnostic.goto_next({
		count = 1,
		severity = vim.diagnostic.severity.ERROR,
		float = float_options,
	})
end

function M.prev_error()
	vim.diagnostic.jump({
		count = -1,
		severity = vim.diagnostic.severity.ERROR,
		float = float_options,
	})
end

function M.next_diag()
	vim.diagnostic.jump({
		count = 1,
		float = float_options,
	})
end

function M.prev_diag()
	vim.diagnostic.jump({
		count = -1,
		float = float_options,
	})
end

function M.format_buffer()
	local conform = require("conform")
	local cursor_position = vim.api.nvim_win_get_cursor(0)
	vim.api.nvim_exec([[%s/\s\+$//e]], false)
	vim.cmd("noh")

	conform.format({
		async = true,
		lsp_fallback = true,
	})

	vim.api.nvim_win_set_cursor(0, cursor_position)
end

M.format_enabled = true
vim.g.disable_autoformat = not M.format_enabled

function M.toggle_format_enabled()
	M.format_enabled = not M.format_enabled
	vim.g.disable_autoformat = not M.format_enabled
	require("utils").refresh_statusline()
end

M.copilot_enabled = true
vim.g.disable_completion = not M.copilot_enabled

function M.toggle_copilot()
	M.copilot_enabled = not M.copilot_enabled
	vim.g.disable_completion = not M.copilot_enabled

	local ok, codeium = pcall(require, "codeium")
	if ok and codeium.toggle then
		codeium.toggle()
	end

	require("utils").refresh_statusline()
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		local L = require("native.lsp-native")
		if L.format_enabled then
			L.format_buffer()
		end
	end,
})

return M

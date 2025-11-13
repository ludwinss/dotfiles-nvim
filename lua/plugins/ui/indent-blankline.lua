local context_char = "│"
local char = "┆"

local function to_hex(color)
	if type(color) ~= "number" or color < 0 then
		return nil
	end
	return string.format("#%06x", color)
end

local function hl_color(group, attr, fallback)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
	if ok and hl[attr] then
		local value = to_hex(hl[attr])
		if value then
			return value
		end
	end
	return fallback
end

local function apply_highlights()
	local base = hl_color("LineNr", "fg", nil) or hl_color("Comment", "fg", "#3a3a3a")
	local context = hl_color("CursorLineNr", "fg", nil) or hl_color("Normal", "fg", base)
	vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = base, nocombine = true })
	vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", { fg = context, nocombine = true })
end

apply_highlights()

local group = vim.api.nvim_create_augroup("indent_blankline_dynamic_highlights", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	callback = apply_highlights,
})

require("ibl").setup({
	exclude = {
		filetypes = { "NvimTree", "startify", "dashboard", "help", "markdown" },
	},
	scope = {
		enabled = true,
		show_start = false,
		show_end = false,
		char = { context_char },
		highlight = { "IndentBlanklineContextChar", "IndentBlanklineContextChar" },
	},
	indent = {
		char = { char },
		highlight = { "IndentBlanklineChar", "IndentBlanklineChar" },
	},
})

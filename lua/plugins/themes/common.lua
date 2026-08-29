local U = require("utils")

local M = {}

local function to_hex(color)
	if type(color) == "number" and color >= 0 then
		return string.format("#%06x", color)
	end
	return color
end

local function highlight(name)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
	if not ok then
		return {}
	end
	return {
		fg = to_hex(hl.fg),
		bg = to_hex(hl.bg),
		sp = to_hex(hl.sp),
	}
end

local function pick(...)
	for _, value in ipairs({ ... }) do
		if value and value ~= "" then
			return value
		end
	end
end

function M.apply(opts)
	opts = opts or {}

	local normal = highlight("Normal")
	local normal_float = highlight("NormalFloat")
	local float_border = highlight("FloatBorder")
	local comment = highlight("Comment")
	local title = highlight("Title")
	local string_hl = highlight("String")
	local type_hl = highlight("Type")
	local constant = highlight("Constant")
	local pmenu_sel = highlight("PmenuSel")
	local line_nr = highlight("LineNr")
	local keyword = highlight("Keyword")
	local special = highlight("Special")
	local error_hl = highlight("DiagnosticError")
	local func_hl = highlight("Function")

	local bg = pick(opts.bg, normal.bg, normal_float.bg, vim.o.background == "light" and "#f6f7fb" or "#181b24")
	local float_bg = pick(opts.float_bg, normal_float.bg, bg)
	local border = pick(opts.border, float_border.fg, comment.fg, line_nr.fg, "#7c6f64")
	local accent = pick(opts.accent, string_hl.fg, type_hl.fg, constant.fg, title.fg, "#d79921")
	local accent_alt = pick(opts.accent_alt, type_hl.fg, constant.fg, title.fg, accent)
	local muted = pick(opts.muted, comment.fg, line_nr.fg, "#928374")
	local select_bg = pick(opts.select_bg, pmenu_sel.bg, float_bg)
	local title_bg = pick(opts.title_bg, bg, float_bg)

	local label_bg = opts.bg or normal.bg or normal_float.bg or (vim.o.background == "light" and "#f6f7fb" or "#181b24")

	local label = opts.label or error_hl.fg or keyword.fg or special.fg or func_hl.fg
	if not label or label == accent or label == accent_alt then
		label = special.fg or func_hl.fg or error_hl.fg or accent_alt
	end
	if not label or label == accent or label == accent_alt then
		label = vim.o.background == "light" and "#c4006a" or "#ff007c"
	end

	U.merge_highlights_table({
		CmpItemSel = { link = "PmenuSel" },
		TelescopeSelection = { bg = select_bg },
		TelescopeSelectionCaret = { fg = accent, bold = true },
		TelescopeMatching = { fg = accent, bold = true, underline = true },
		TelescopeMatchingSelection = { fg = accent_alt, bold = true, underline = true },
		TelescopePromptTitle = { fg = bg, bg = accent, bold = true },
		TelescopePreviewTitle = { fg = bg, bg = accent_alt, bold = true },
		TelescopeBorder = { fg = border, bg = float_bg },
		TelescopePromptBorder = { fg = border, bg = float_bg },
		TelescopePromptNormal = { bg = float_bg },
		TelescopeNormal = { bg = float_bg },
		WhichKeyBorder = { fg = border, bg = float_bg },
		WhichKeyNormal = { bg = float_bg },
		WhichKeyTitle = { fg = accent_alt, bg = title_bg, bold = true },
		NoiceCmdlinePopupBorder = { fg = border, bg = float_bg },
		NoicePopupBorder = { fg = border, bg = float_bg },
		NoiceCmdlineIcon = { fg = accent },
		NoiceLspProgressTitle = { bg = bg },
		NoiceLspProgressClient = { bg = bg },
		NoiceLspProgressSpinner = { bg = bg },
		DapUINormal = { bg = float_bg },
		NotifyBackground = { bg = bg },
		IndentBlanklineChar = { fg = muted },
		IndentBlanklineContextChar = { fg = border },
		CustomWinBar = { fg = muted },
		CustomWinBarNC = { fg = muted },
		WinBar = { fg = muted },
		WinBarNC = { fg = muted },
		LeapBackdrop = {},
		LeapLabelPrimary = { fg = label_bg, bg = label, bold = true },
		LeapLabelSecondary = { fg = label_bg, bg = accent_alt, bold = true },
	})

	for group, hl in pairs({
		FlashBackdrop = { fg = muted },
		FlashMatch = { fg = label_bg, bg = accent, bold = true },
		FlashCurrent = { fg = label_bg, bg = accent_alt, bold = true },
		FlashLabel = { fg = label_bg, bg = label, bold = true },
		FlashPromptIcon = { fg = label },
	}) do
		vim.api.nvim_set_hl(0, group, hl)
	end

	U.refresh_statusline()
end

function M.attach(theme_name, opts)
	local group = vim.api.nvim_create_augroup("theme_overrides_" .. theme_name:gsub("%W", "_"), { clear = true })

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		pattern = theme_name,
		callback = function()
			M.apply(opts)
		end,
	})

	if vim.g.colors_name == theme_name then
		M.apply(opts)
	end
end

return M

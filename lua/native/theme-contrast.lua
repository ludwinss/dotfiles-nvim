local U = require("utils")

local M = {}

local function to_hex(color)
	if type(color) == "number" and color >= 0 then
		return string.format("#%06x", color)
	end
	return color
end

local function from_hex(hex)
	if type(hex) ~= "string" then
		return
	end
	hex = hex:gsub("#", "")
	if #hex ~= 6 then
		return
	end
	return {
		r = tonumber(hex:sub(1, 2), 16),
		g = tonumber(hex:sub(3, 4), 16),
		b = tonumber(hex:sub(5, 6), 16),
	}
end

local function clamp(value)
	return math.max(0, math.min(255, math.floor(value + 0.5)))
end

local function blend(fg, bg, alpha)
	local a = from_hex(fg)
	local b = from_hex(bg)
	if not a or not b then
		return fg or bg
	end
	return string.format(
		"#%02x%02x%02x",
		clamp((alpha * a.r) + ((1 - alpha) * b.r)),
		clamp((alpha * a.g) + ((1 - alpha) * b.g)),
		clamp((alpha * a.b) + ((1 - alpha) * b.b))
	)
end

local function luminance(hex)
	local rgb = from_hex(hex)
	if not rgb then
		return 0
	end

	local function channel(v)
		v = v / 255
		if v <= 0.03928 then
			return v / 12.92
		end
		return ((v + 0.055) / 1.055) ^ 2.4
	end

	return 0.2126 * channel(rgb.r) + 0.7152 * channel(rgb.g) + 0.0722 * channel(rgb.b)
end

local function contrast_ratio(fg, bg)
	local l1 = luminance(fg)
	local l2 = luminance(bg)
	local lighter = math.max(l1, l2)
	local darker = math.min(l1, l2)
	return (lighter + 0.05) / (darker + 0.05)
end

local function ensure_contrast(fg, bg, min_ratio)
	if not fg or not bg then
		return fg
	end
	if contrast_ratio(fg, bg) >= min_ratio then
		return fg
	end

	local target = vim.o.background == "light" and "#11131a" or "#f2f4f8"
	local alpha = 0.15
	local current = fg

	while alpha <= 1 do
		current = blend(target, current, alpha)
		if contrast_ratio(current, bg) >= min_ratio then
			return current
		end
		alpha = alpha + 0.1
	end

	return target
end

local function hl(name)
	local ok, value = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
	if not ok then
		return {}
	end
	return {
		fg = to_hex(value.fg),
		bg = to_hex(value.bg),
		sp = to_hex(value.sp),
	}
end

local function pick(...)
	for _, value in ipairs({ ... }) do
		if value and value ~= "" then
			return value
		end
	end
end

function M.apply()
	local normal = hl("Normal")
	local comment = hl("Comment")
	local line_nr = hl("LineNr")
	local string_hl = hl("String")
	local function_hl = hl("Function")
	local type_hl = hl("Type")
	local keyword = hl("Keyword")
	local identifier = hl("Identifier")
	local error = hl("DiagnosticError")
	local warn = hl("DiagnosticWarn")
	local ok = hl("DiagnosticOk")

	local bg = pick(normal.bg, vim.o.background == "light" and "#fbf1c7" or "#1d2021")
	local fg = ensure_contrast(pick(normal.fg, vim.o.background == "light" and "#3c3836" or "#ebdbb2"), bg, 7)
	local muted = ensure_contrast(pick(comment.fg, line_nr.fg, blend(fg, bg, 0.45)), bg, 3.2)
	local subtle = ensure_contrast(pick(line_nr.fg, muted), bg, 2.4)
	local accent = ensure_contrast(pick(string_hl.fg, function_hl.fg, type_hl.fg, "#d79921"), bg, 4.2)
	local accent_alt = ensure_contrast(pick(type_hl.fg, keyword.fg, identifier.fg, "#458588"), bg, 4.2)
	local error_fg = ensure_contrast(pick(error.fg, "#cc241d"), bg, 4.5)
	local warn_fg = ensure_contrast(pick(warn.fg, "#d79921"), bg, 4.5)
	local ok_fg = ensure_contrast(pick(ok.fg, "#98971a"), bg, 4.5)
	local info_fg = ensure_contrast(pick(hl("DiagnosticInfo").fg, accent_alt), bg, 4.5)

	local elevated = blend(fg, bg, vim.o.background == "light" and 0.08 or 0.12)
	local elevated_2 = blend(fg, bg, vim.o.background == "light" and 0.14 or 0.2)
	local visual_bg = blend(accent_alt, bg, vim.o.background == "light" and 0.22 or 0.28)
	local oil_bg = blend(fg, bg, vim.o.background == "light" and 0.04 or 0.06)

	U.merge_highlights_table({
		Normal = { fg = fg },
		Comment = { fg = muted },
		LineNr = { fg = subtle },
		CursorLineNr = { fg = accent_alt, bold = true },
		Visual = { bg = visual_bg },
		StatusLine = { fg = fg, bg = elevated },
		StatusLineNC = { fg = muted, bg = elevated },
		WinBar = { fg = muted, bg = bg },
		WinBarNC = { fg = muted, bg = bg },
		Pmenu = { fg = fg, bg = elevated },
		PmenuSel = { fg = fg, bg = elevated_2, bold = true },
		NormalFloat = { fg = fg, bg = elevated },
		FloatBorder = { fg = accent_alt, bg = elevated },
		WhichKeyBorder = { fg = accent_alt, bg = elevated },
		WhichKeyTitle = { fg = accent, bg = elevated, bold = true },
		TelescopeBorder = { fg = accent_alt, bg = elevated },
		TelescopePromptBorder = { fg = accent_alt, bg = elevated },
		TelescopePromptTitle = { fg = bg, bg = accent, bold = true },
		TelescopePreviewTitle = { fg = bg, bg = accent_alt, bold = true },
		TelescopeNormal = { bg = elevated },
		TelescopePromptNormal = { bg = elevated },
		TelescopeSelection = { bg = elevated_2 },
		TelescopeMatching = { fg = accent, bold = true, underline = true },
		NoiceCmdlinePopupBorder = { fg = accent_alt, bg = elevated },
		NoicePopupBorder = { fg = accent_alt, bg = elevated },
		IndentBlanklineChar = { fg = subtle },
		IndentBlanklineContextChar = { fg = accent_alt },
		DiagnosticError = { fg = error_fg },
		DiagnosticWarn = { fg = warn_fg },
		DiagnosticOk = { fg = ok_fg },
		DiagnosticInfo = { fg = info_fg },
		["@comment"] = { fg = muted, italic = true },
		["@comment.documentation"] = { fg = muted, italic = true },
		["@keyword.return"] = { fg = accent_alt, bold = true },
		["@keyword.import"] = { fg = accent_alt, bold = true },
		["@keyword.operator"] = { fg = accent_alt, bold = true },
		["@keyword"] = { fg = accent_alt },
		["@keyword.function"] = { fg = accent_alt, bold = true },
		["@function"] = { fg = accent },
		["@function.method"] = { fg = accent },
		["@function.call"] = { fg = accent },
		["@function.builtin"] = { fg = accent_alt, bold = true },
		["@method"] = { fg = accent },
		["@type"] = { fg = accent_alt },
		["@type.builtin"] = { fg = accent_alt, bold = true },
		["@type.definition"] = { fg = accent_alt, bold = true },
		["@constructor"] = { fg = accent_alt, bold = true },
		["@constant"] = { fg = accent },
		["@constant.builtin"] = { fg = accent_alt, bold = true },
		["@constant.macro"] = { fg = accent_alt, bold = true },
		["@string"] = { fg = accent },
		["@string.escape"] = { fg = accent_alt, bold = true },
		["@number"] = { fg = accent },
		["@boolean"] = { fg = accent_alt, bold = true },
		["@operator"] = { fg = accent_alt },
		["@punctuation.bracket"] = { fg = subtle },
		["@punctuation.delimiter"] = { fg = subtle },
		["@tag"] = { fg = accent_alt },
		["@tag.attribute"] = { fg = accent },
		["@tag.delimiter"] = { fg = subtle },
		["@property"] = { fg = fg },
		["@variable"] = { fg = fg },
		["@variable.builtin"] = { fg = accent_alt, italic = true },
		["@variable.member"] = { fg = fg },
		OilDir = { fg = accent_alt, bg = oil_bg, bold = true },
		OilDirIcon = { fg = accent_alt, bg = oil_bg, bold = true },
		OilFile = { fg = fg, bg = oil_bg },
		OilHidden = { fg = muted, bg = oil_bg, italic = true },
		OilDirHidden = { fg = muted, bg = oil_bg, italic = true },
		OilFileHidden = { fg = muted, bg = oil_bg, italic = true },
		OilLink = { fg = accent, bg = oil_bg, underline = true },
		OilLinkTarget = { fg = fg, bg = oil_bg },
		OilOrphanLink = { fg = error_fg, bg = oil_bg, underline = true },
		OilOrphanLinkTarget = { fg = error_fg, bg = oil_bg },
		OilSocket = { fg = warn_fg, bg = oil_bg },
		OilCreate = { fg = ok_fg, bg = oil_bg, bold = true },
		OilDelete = { fg = error_fg, bg = oil_bg, bold = true },
		OilMove = { fg = accent_alt, bg = oil_bg, bold = true },
		OilCopy = { fg = accent, bg = oil_bg, bold = true },
		OilChange = { fg = warn_fg, bg = oil_bg, bold = true },
	})

	U.refresh_statusline()
end

local group = vim.api.nvim_create_augroup("theme_global_contrast", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	pattern = "*",
	callback = function()
		M.apply()
	end,
})

vim.schedule(function()
	M.apply()
end)

return M

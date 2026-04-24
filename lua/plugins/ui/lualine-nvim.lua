local U = require("utils")
local lsp_native = require("native.lsp-native")

local M = {}

local function to_hex(color)
	if type(color) == "number" and color >= 0 then
		return string.format("#%06x", color)
	end
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

local function hl_color(group, attr)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
	if ok and hl[attr] then
		return to_hex(hl[attr])
	end
end

local function pick(...)
	for _, value in ipairs({ ... }) do
		if value and value ~= "" then
			return value
		end
	end
end

local function try_require(mod)
	local ok, value = pcall(require, mod)
	if ok then
		return value
	end
end

local function resolve_lualine_theme(colors_name)
	if not colors_name or colors_name == "" then
		return
	end

	return try_require("lualine.themes." .. colors_name)
		or try_require("lualine.themes." .. colors_name:gsub("%-", "_"))
		or try_require("lualine.themes." .. colors_name:gsub("%.", "_"))
end

local function capture_highlight(name)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
	if not ok then
		return {}
	end
	return {
		fg = to_hex(hl.fg),
		bg = to_hex(hl.bg),
	}
end

local function default_fg()
	return vim.o.background == "light" and "#11131a" or "#e6e8ee"
end

local function default_bg()
	return vim.o.background == "light" and "#f6f7fb" or "#181b24"
end

local function build_dynamic_theme(palette)
	local status = capture_highlight("StatusLine")
	local status_nc = capture_highlight("StatusLineNC")
	local normal = capture_highlight("Normal")
	local base_bg = normal.bg or status.bg or default_bg()
	local section_bg = blend(palette.text or default_fg(), base_bg, vim.o.background == "light" and 0.08 or 0.12)
	local section_bg_alt = blend(palette.text or default_fg(), base_bg, vim.o.background == "light" and 0.12 or 0.18)
	local base_fg = ensure_contrast(palette.text or normal.fg or status.fg or default_fg(), section_bg, 7)
	local inactive_fg = ensure_contrast(status_nc.fg or palette.dim or base_fg, section_bg, 4.5)
	local inactive_bg = status_nc.bg or section_bg

	local function strong(color)
		local bg = color or base_fg
		local fg = ensure_contrast(base_bg, bg, 5.5)
		return { fg = fg, bg = bg, gui = "bold" }
	end

	local neutral = { fg = base_fg, bg = section_bg }
	local neutral_alt = { fg = base_fg, bg = section_bg_alt }
	local inactive = { fg = inactive_fg, bg = inactive_bg }

	local insert = ensure_contrast(hl_color("String", "fg") or palette.green, section_bg, 4.5)
	local visual = ensure_contrast(hl_color("Type", "fg") or palette.red, section_bg, 4.5)
	local command = ensure_contrast(hl_color("Constant", "fg") or palette.green, section_bg, 4.5)
	local terminal = ensure_contrast(hl_color("Identifier", "fg") or palette.green, section_bg, 4.5)
	local replace = ensure_contrast(palette.red, section_bg, 4.5)
	local normal_mode = ensure_contrast(palette.green, section_bg, 4.5)

	return {
		normal = { a = strong(normal_mode), b = neutral_alt, c = neutral },
		insert = { a = strong(insert), b = neutral_alt, c = neutral },
		replace = { a = strong(replace), b = neutral_alt, c = neutral },
		visual = { a = strong(visual), b = neutral_alt, c = neutral },
		command = { a = strong(command), b = neutral_alt, c = neutral },
		terminal = { a = strong(terminal), b = neutral_alt, c = neutral },
		inactive = { a = inactive, b = inactive, c = inactive },
	}
end

local function resolve_theme()
	local palette = {
		text = pick(hl_color("Normal", "fg"), hl_color("StatusLine", "fg"), default_fg()),
		dim = pick(hl_color("StatusLineNC", "fg"), hl_color("LineNr", "fg"), hl_color("Comment", "fg"), default_fg()),
		green = pick(hl_color("DiagnosticOk", "fg"), hl_color("DiffAdd", "fg"), hl_color("String", "fg"), "#8ec07c"),
		red = pick(hl_color("DiagnosticError", "fg"), hl_color("DiffDelete", "fg"), hl_color("Error", "fg"), "#f7768e"),
	}

	local colors_name = type(vim.g.colors_name) == "string" and vim.g.colors_name or nil
	if colors_name and colors_name ~= "" then
		palette.lualine = resolve_lualine_theme(colors_name)
	end

	if not palette.lualine and (colors_name == nil or colors_name == "" or colors_name == "default") then
		local ok, default_theme = pcall(require, "native.default-theme")
		if ok and default_theme.get_lualine_theme then
			palette.lualine = default_theme.get_lualine_theme()
		end
	end

	if not palette.lualine then
		palette.lualine = build_dynamic_theme(palette)
	end

	return palette
end

local function fmt_mode(mode)
	local map = {
		["COMMAND"] = "COMMND",
		["V-BLOCK"] = "V-BLCK",
		["TERMINAL"] = "TERMNL",
		["V-REPLACE"] = "V-RPLC",
		["O-PENDING"] = "OPNDNG",
	}
	return map[mode] or mode
end

local function diff_source()
	local gitsigns = vim.b.gitsigns_status_dict
	if not gitsigns then
		return nil
	end
	return {
		added = gitsigns.added,
		modified = gitsigns.changed,
		removed = gitsigns.removed,
	}
end

local default_z = {
	{
		"location",
		icon = { "", align = "left" },
		fmt = function(str)
			return string.format("%7s", str)
		end,
		padding = { left = 1, right = 1 },
	},
	{
		"progress",
		icon = { "", align = "left" },
		padding = { left = 1, right = 1 },
	},
}

local function safe_enabled(fn)
	local ok, value = pcall(fn)
	if ok then
		return value
	end
	return false
end

local function build_status_component(opts)
	return {
		function()
			local enabled = safe_enabled(opts.enabled)
			return opts.icon
		end,
		color = function()
			local enabled = safe_enabled(opts.enabled)
			if enabled then
				return opts.colors.on
			end
			return opts.colors.off
		end,
		padding = opts.padding or { left = 0, right = 1 },
	}
end

function M.setup()
	local palette = resolve_theme()
	local text_hl = palette.text and { fg = palette.text } or nil
	local icon_hl = palette.dim and { fg = palette.dim } or text_hl
	local green = palette.green
	local red = palette.red
	local lualine_theme = palette.lualine
	local status_colors = {
		on = { fg = green or "#7ef29d", bg = "NONE" },
		off = { fg = red or "#ff6b6b", bg = "NONE" },
	}

	local function recording_color()
		if U.is_recording() then
			return red and { fg = red } or text_hl
		end
		return text_hl
	end

	local tree = {
		sections = {
			lualine_a = {
				{ "mode", fmt = fmt_mode, icon = { "" }, padding = { left = 1, right = 1 } },
			},
			lualine_b = {},
			lualine_c = {
				{
					U.get_short_cwd,
					padding = { left = 1, right = 1 },
					icon = { "", color = icon_hl },
					color = text_hl,
				},
			},
			lualine_x = {},
			lualine_y = {},
			lualine_z = default_z,
		},
		filetypes = { "NvimTree" },
	}

	local telescope = {
		sections = {
			lualine_a = {
				{ "mode", fmt = fmt_mode, icon = { "" }, padding = { left = 1, right = 1 } },
			},
			lualine_b = {},
			lualine_c = {
				{
					function()
						return "Telescope"
					end,
					color = text_hl,
					icon = { "  ", color = icon_hl },
					padding = { left = 1, right = 1 },
				},
			},
			lualine_x = {},
			lualine_y = {},
			lualine_z = default_z,
		},
		filetypes = { "TelescopePrompt" },
	}

	local options = {
		globalstatus = true,
		disabled_filetypes = { statusline = { "dashboard" } },
		section_separators = { left = "", right = "" },
		component_separators = { left = "", right = "" },
		theme = lualine_theme,
	}

	require("lualine").setup({
		sections = {
			lualine_a = {
				{ "mode", fmt = fmt_mode, icon = { "" }, padding = { left = 1, right = 1 } },
			},
			lualine_b = {},
			lualine_c = {
				{ U.get_recording_state_icon, color = recording_color, padding = { left = 1, right = 1 } },
				{ "branch", color = text_hl, icon = { " ", color = icon_hl }, padding = 0 },
				{
					"diff",
					color = text_hl,
					icon = { " ", color = text_hl },
					source = diff_source,
					symbols = { added = " ", modified = " ", removed = " " },
					diff_color = {
						added = green and { fg = green } or icon_hl,
						modified = icon_hl,
						removed = red and { fg = red } or icon_hl,
					},
					padding = 0,
				},
			},
			lualine_x = {
				{
					"diagnostics",
					sources = { "nvim_diagnostic" },
					symbols = {
						error = U.diagnostic_signs.error,
						warn = U.diagnostic_signs.warn,
						info = U.diagnostic_signs.info,
						hint = U.diagnostic_signs.hint,
						other = U.diagnostic_signs.other,
					},
					colored = true,
					padding = { left = 1, right = 1 },
				},
				{
					U.current_buffer_lsp,
					padding = { left = 1, right = 1 },
					color = text_hl,
					icon = { " ", color = icon_hl },
				},
			},
			lualine_y = {
				build_status_component({
					icon = " ",
					enabled = function()
						return lsp_native.is_copilot_active and lsp_native.is_copilot_active()
					end,
					colors = status_colors,
				}),
				build_status_component({
					icon = " ",
					enabled = function()
						if lsp_native.is_virtual_diagnostics_active then
							return lsp_native.is_virtual_diagnostics_active()
						end
						return false
					end,
					colors = status_colors,
				}),
				build_status_component({
					icon = "󰉢 ",
					enabled = function()
						return lsp_native.is_format_active()
					end,
					colors = status_colors,
				}),
			},
			lualine_z = default_z,
		},
		options = options,
		extensions = {
			telescope,
			tree,
		},
	})
end

M.setup()

local group = vim.api.nvim_create_augroup("lualine_dynamic_theme", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	callback = function()
		pcall(function()
			require("plugins.ui.lualine-nvim").setup()
		end)
	end,
})

return M

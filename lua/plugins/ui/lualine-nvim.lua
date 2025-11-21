local U = require("utils")
local lsp_native = require("native.lsp-native")

local M = {}

local function to_hex(color)
	if type(color) == "number" and color >= 0 then
		return string.format("#%06x", color)
	end
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
	local base_bg = status.bg or default_bg()
	local base_fg = palette.text or status.fg or default_fg()
	local inactive_fg = status_nc.fg or palette.dim or base_fg
	local inactive_bg = status_nc.bg or base_bg

	local function strong(color)
		return { fg = base_bg, bg = color or base_fg, gui = "bold" }
	end

	local neutral = { fg = base_fg, bg = base_bg }
	local inactive = { fg = inactive_fg, bg = inactive_bg }

	local insert = hl_color("String", "fg") or palette.green
	local visual = hl_color("Type", "fg") or palette.red
	local command = hl_color("Constant", "fg") or palette.green
	local terminal = hl_color("Identifier", "fg") or palette.green

	return {
		normal = { a = strong(palette.green), b = neutral, c = neutral },
		insert = { a = strong(insert), b = neutral, c = neutral },
		replace = { a = strong(palette.red), b = neutral, c = neutral },
		visual = { a = strong(visual), b = neutral, c = neutral },
		command = { a = strong(command), b = neutral, c = neutral },
		terminal = { a = strong(terminal), b = neutral, c = neutral },
		inactive = { a = inactive, b = inactive, c = inactive },
	}
end

local function resolve_theme()
	local palette = {
		text = pick(
			hl_color("Normal", "fg"),
			hl_color("StatusLine", "fg"),
			default_fg()
		),
		dim = pick(
			hl_color("StatusLineNC", "fg"),
			hl_color("LineNr", "fg"),
			hl_color("Comment", "fg"),
			default_fg()
		),
		green = pick(
			hl_color("DiagnosticOk", "fg"),
			hl_color("DiffAdd", "fg"),
			hl_color("String", "fg"),
			"#8ec07c"
		),
		red = pick(
			hl_color("DiagnosticError", "fg"),
			hl_color("DiffDelete", "fg"),
			hl_color("Error", "fg"),
			"#f7768e"
		),
	}

	local colors_name = type(vim.g.colors_name) == "string" and vim.g.colors_name or nil
	if colors_name and colors_name ~= "" then
		palette.lualine = try_require("lualine.themes." .. colors_name)
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

function M.setup()
	local palette = resolve_theme()
	local text_hl = palette.text and { fg = palette.text } or nil
	local icon_hl = palette.dim and { fg = palette.dim } or text_hl
	local green = palette.green
	local red = palette.red
	local lualine_theme = palette.lualine

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
				{ U.get_recording_state_icon, color = recording_color, padding = 0 },
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
				{ U.current_buffer_lsp, padding = { left = 1, right = 1 }, color = text_hl, icon = { " ", color = icon_hl } },
			},
			lualine_y = {},
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

local CMP = require("cmp")
local compare = require("cmp.config.compare")
local U = require("utils")

local function format(_, item)
	local MAX_LABEL_WIDTH = 55
	local function whitespace(max, len)
		return (" "):rep(max - len)
	end

	local content = item.abbr
	if #content > MAX_LABEL_WIDTH then
		item.abbr = vim.fn.strcharpart(content, 0, MAX_LABEL_WIDTH) .. "…"
	else
		item.abbr = content .. whitespace(MAX_LABEL_WIDTH, #content)
	end

	item.kind = " " .. (U.kind_icons[item.kind] or U.kind_icons.Unknown) .. "│"

	item.menu = nil
	return item
end

local formatting = {
	fields = { "kind", "abbr" },
	format = format,
}

local window = {
	completion = CMP.config.window.bordered({
		winhighlight = "Normal:Pmenu,FloatBorder:SpecialCmpBorder,CursorLine:PmenuSel,Search:None",
		scrollbar = true,
		border = "rounded",
		col_offset = -1,
		side_padding = 0,
	}),
	documentation = CMP.config.window.bordered({
		winhighlight = "Normal:Pmenu,FloatBorder:SpecialCmpBorder,CursorLine:PmenuSel,Search:None",
		scrollbar = true,
		border = "rounded",
	}),
}

local sources = CMP.config.sources({
	{ name = "nvim_lsp" },
	{ name = "luasnip" },
	{ name = "codeium" },
})

window.documentation.max_height = 18
window.documentation.max_width = 80
window.documentation.side_padding = 1

CMP.setup({
	formatting = formatting,
	window = window,
	sources = sources,
	sorting = {
		priority_weight = 2,
		comparators = {
			compare.sort_text,
			compare.score,
			compare.recently_used,
			compare.locality,
			compare.exact,
			compare.kind,
			compare.length,
			compare.order,
		},
	},
	performance = {
		debounce = 50,
	},
})

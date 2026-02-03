require("nordic").setup({
	italic_comments = true,
	transparent = {
		bg = false,
		float = false,
	},
	on_highlight = function(highlights, pallette)
		highlights.Visual = { bg = pallette.orange.base, fg = pallette.black2 }
		highlights.PmenuSel = { bg = pallette.white2, fg = pallette.black2 }
		highlights.CmpItemSel = { link = "PmenuSel" }
		highlights.TelescopeSelection = { bg = pallette.white2, fg = pallette.black2 }
		highlights.TelescopeSelectionCaret = { bg = pallette.white2, fg = pallette.black2, bold = true }
		return highlights
	end,
})

require("nordic").load({
	cursorline = {
		theme = "dark",
	},
})

require("lualine").setup({
	options = { theme = "nordic" },
})

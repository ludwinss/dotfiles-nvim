local CMP = require("cmp")
local codeium = require("codeium")
local U = require("utils")

require("plugins.ui.nvim-cmp")
require("luasnip.loaders.from_vscode").lazy_load()

local sources = CMP.config.sources({
	{ name = "nvim_lsp" },
	{ name = "luasnip" },
	{ name = "path" },
})
local snippet = {
	expand = function(args)
		require("luasnip").lsp_expand(args.body)
	end,
}
CMP.setup({
	sources = sources,
	snippet = snippet,
})

local tex = {
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "latex_symbols" },
	},
}
CMP.setup.filetype({ "tex", "latex" }, tex)

local cmdline_window = {
	completion = CMP.config.window.bordered({
		winhighlight = "Normal:Pmenu,FloatBorder:SpecialCmpBorder,CursorLine:PmenuSel,Search:None",
		scrollbar = true,
		border = U.get_border_chars("cmdline"),
		col_offset = -4,
		side_padding = 0,
	}),
}
local cmdline = {
	window = cmdline_window,
	mapping = CMP.mapping.preset.cmdline(),
	sources = CMP.config.sources({
		{ name = "cmdline" },
		{ name = "path" },
	}),
}
CMP.setup.cmdline({ ":", ":!" }, cmdline)

local search_window = {
	completion = CMP.config.window.bordered({
		winhighlight = "Normal:Pmenu,FloatBorder:SpecialCmpBorder,CursorLine:PmenuSel,Search:None",
		scrollbar = true,
		border = U.get_border_chars("search"),
		col_offset = -1,
		side_padding = 0,
	}),
}

local mapping = CMP.mapping.preset.insert({
	["<C-j>"] = CMP.mapping.select_next_item({ behavior = CMP.SelectBehavior.Select }),
	["<C-k>"] = CMP.mapping.select_prev_item({ behavior = CMP.SelectBehavior.Select }),
	["<C-e>"] = CMP.mapping.abort(),

	["<CR>"] = function(fallback)
		if CMP.visible() then
			CMP.confirm({ select = false })
		else
			local ok = pcall(codeium.accept)
			if not ok then
				fallback()
			end
		end
	end,

	["<C-l>"] = function()
		pcall(codeium.accept_word)
	end,
	["<C-;>"] = function()
		pcall(codeium.accept_line)
	end,
})

local search = {
	window = search_window,
	mapping = mapping,
	sources = CMP.config.sources({ { name = "buffer" } }),
	completion = {
		autocomplete = false,
	},
}
CMP.setup.cmdline({ "/", "?" }, search)

vim.api.nvim_create_autocmd("User", {
	pattern = "CmpMenuOpened",
	callback = function()
		pcall(require("codeium").clear)
	end,
})

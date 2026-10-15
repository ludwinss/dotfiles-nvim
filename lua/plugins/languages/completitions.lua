local CMP = require("cmp")
local luasnip = require("luasnip")
local U = require("utils")

require("plugins.ui.nvim-cmp")
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_lua").lazy_load({
	paths = vim.fn.stdpath("config") .. "/lua/snippets",
})

local insert_mapping = {
	["<C-Space>"] = CMP.mapping.complete(),
	-- Algunas terminales envían Ctrl-Space como Ctrl-@ (NUL).
	["<C-@>"] = CMP.mapping.complete(),
	["<C-d>"] = CMP.mapping.scroll_docs(4),
	["<C-u>"] = CMP.mapping.scroll_docs(-4),
	["<CR>"] = CMP.mapping(function(fallback)
		if CMP.visible() and CMP.get_selected_entry() then
			CMP.confirm({ behavior = CMP.ConfirmBehavior.Replace, select = false })
		else
			fallback()
		end
	end, { "i", "s" }),
	["<C-j>"] = CMP.mapping.select_next_item({ behavior = CMP.SelectBehavior.Select }),
	["<C-k>"] = CMP.mapping.select_prev_item({ behavior = CMP.SelectBehavior.Select }),
}

local sources = CMP.config.sources({
	{ name = "nvim_lsp" },
	{ name = "luasnip" },
	{ name = "path" },
	{ name = "buffer" },
})
local snippet = {
	expand = function(args)
		require("luasnip").lsp_expand(args.body)
	end,
}
CMP.setup({
	sources = sources,
	snippet = snippet,
	mapping = insert_mapping,
	preselect = CMP.PreselectMode.None,
})

vim.keymap.set({ "i", "s" }, "<Tab>", function()
	if CMP.visible() then
		vim.schedule(function()
			CMP.select_next_item({ behavior = CMP.SelectBehavior.Select })
		end)
		return ""
	end

	if luasnip.expand_or_locally_jumpable() then
		vim.schedule(luasnip.expand_or_jump)
		return ""
	end

	return "<Tab>"
end, { expr = true, silent = true, desc = "Siguiente item o avanzar snippet" })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
	if CMP.visible() then
		vim.schedule(function()
			CMP.select_prev_item({ behavior = CMP.SelectBehavior.Select })
		end)
		return ""
	end

	if luasnip.jumpable(-1) then
		vim.schedule(function()
			luasnip.jump(-1)
		end)
		return ""
	end

	return "<S-Tab>"
end, { expr = true, silent = true, desc = "Retroceder snippet" })

local cmdline_window = {
	completion = CMP.config.window.bordered({
		winhighlight = "Normal:Pmenu,FloatBorder:SpecialCmpBorder,CursorLine:PmenuSel,Search:None",
		scrollbar = true,
		border = U.get_border_chars("cmdline"),
		col_offset = -4,
		side_padding = 0,
	}),
}

local function cmdline_mapping()
	return CMP.mapping.preset.cmdline({
		["<CR>"] = CMP.mapping(function(fallback)
			if CMP.visible() and CMP.get_selected_entry() then
				CMP.confirm({ select = false })
			else
				fallback()
			end
		end, { "c" }),
		["<C-j>"] = CMP.mapping(function()
			if CMP.visible() then
				CMP.select_next_item({ behavior = CMP.SelectBehavior.Select })
			else
				CMP.complete()
			end
		end, { "c" }),
		["<C-k>"] = CMP.mapping(function()
			if CMP.visible() then
				CMP.select_prev_item({ behavior = CMP.SelectBehavior.Select })
			else
				CMP.complete()
			end
		end, { "c" }),
	})
end

local cmdline = {
	window = cmdline_window,
	mapping = cmdline_mapping(),
	sources = CMP.config.sources({
		{ name = "cmdline" },
		{ name = "path" },
	}),
}
CMP.setup.cmdline(":", cmdline)

local search_window = {
	completion = CMP.config.window.bordered({
		winhighlight = "Normal:Pmenu,FloatBorder:SpecialCmpBorder,CursorLine:PmenuSel,Search:None",
		scrollbar = true,
		border = U.get_border_chars("search"),
		col_offset = -1,
		side_padding = 0,
	}),
}

local search = {
	window = search_window,
	mapping = cmdline_mapping(),
	sources = CMP.config.sources({ { name = "buffer" } }),
	completion = {
		autocomplete = false,
	},
}
CMP.setup.cmdline({ "/", "?" }, search)

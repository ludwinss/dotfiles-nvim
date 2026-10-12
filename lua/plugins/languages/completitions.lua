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
	["<C-d>"] = CMP.mapping.scroll_docs(4),
	["<C-u>"] = CMP.mapping.scroll_docs(-4),
	["<CR>"] = CMP.mapping(function(fallback)
		if CMP.visible() then
			CMP.confirm({ behavior = CMP.ConfirmBehavior.Replace, select = true })
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
})

local function accept_ai()
	local ok, suggestion = pcall(require, "supermaven-nvim.completion_preview")
	if not ok or not suggestion.has_suggestion() then
		return false
	end

	suggestion.on_accept_suggestion()
	return true
end

vim.keymap.set({ "i", "s" }, "<Tab>", function()
	if luasnip.expand_or_locally_jumpable() then
		luasnip.expand_or_jump()
		return
	end

	if accept_ai() then
		return
	end

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
end, { silent = true, desc = "Aceptar IA o avanzar snippet" })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
	if luasnip.jumpable(-1) then
		luasnip.jump(-1)
		return
	end

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true), "n", false)
end, { silent = true, desc = "Retroceder snippet" })

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

local function cmdline_mapping()
	return CMP.mapping.preset.cmdline({
		["<Tab>"] = CMP.mapping(function() end, { "c" }),
		["<S-Tab>"] = CMP.mapping(function() end, { "c" }),
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

local search = {
	window = search_window,
	mapping = cmdline_mapping(),
	sources = CMP.config.sources({ { name = "buffer" } }),
	completion = {
		autocomplete = false,
	},
}
CMP.setup.cmdline({ "/", "?" }, search)

vim.api.nvim_create_autocmd("User", {
	pattern = "CmpMenuOpened",
	callback = function()
		local ok, suggestion = pcall(require, "supermaven-nvim.completion_preview")
		if ok then
			suggestion.on_dispose_inlay()
		end
	end,
	desc = "Ocultar Supermaven mientras CMP está abierto",
})

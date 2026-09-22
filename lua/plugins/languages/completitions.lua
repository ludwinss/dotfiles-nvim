local CMP = require("cmp")
local luasnip = require("luasnip")
local U = require("utils")

require("plugins.ui.nvim-cmp")
require("luasnip.loaders.from_vscode").lazy_load()

local function accept_ai()
	if not vim.api.nvim_get_mode().mode:match("^i") then
		return false
	end

	local ok, virtual_text = pcall(require, "codeium.virtual_text")
	if not ok or not virtual_text.get_current_completion_item() then
		return false
	end

	local keys = virtual_text.accept()
	if not keys or keys == "" then
		return false
	end

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
	return true
end

-- Contrato minimo para completar en modo Insert:
--   Enter: aceptar CMP.
--   Tab/S-Tab: aceptar IA o moverse por un snippet.
--   C-j/C-k: navegar CMP. C-Space: abrir CMP manualmente.
local insert_mapping = {
	["<C-Space>"] = CMP.mapping.complete(),
	["<CR>"] = CMP.mapping(function(fallback)
		if CMP.visible() then
			CMP.confirm({ behavior = CMP.ConfirmBehavior.Replace, select = true })
		else
			fallback()
		end
	end, { "i", "s" }),
	["<Tab>"] = CMP.mapping(function(fallback)
		if accept_ai() then
			return
		elseif luasnip.expand_or_locally_jumpable() then
			luasnip.expand_or_jump()
		else
			fallback()
		end
	end, { "i", "s" }),
	["<S-Tab>"] = CMP.mapping(function(fallback)
		if luasnip.jumpable(-1) then
			luasnip.jump(-1)
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

local search = {
	window = search_window,
	mapping = CMP.mapping.preset.cmdline(),
	sources = CMP.config.sources({ { name = "buffer" } }),
	completion = {
		autocomplete = false,
	},
}
CMP.setup.cmdline({ "/", "?" }, search)

vim.api.nvim_create_autocmd("User", {
	pattern = "CmpMenuOpened",
	callback = function()
		local ok, virtual_text = pcall(require, "codeium.virtual_text")
		if ok then
			virtual_text.clear()
		end
	end,
})

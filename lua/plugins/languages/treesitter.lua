local parsers = {
	"angular",
	"bash",
	"c",
	"cpp",
	"css",
	"dockerfile",
	"elixir",
	"go",
	"html",
	"javascript",
	"json",
	"kdl",
	"lua",
	"make",
	"markdown",
	"markdown_inline",
	"python",
	"regex",
	"rust",
	"scss",
	"tsx",
	"typescript",
	"vim",
	"xml",
	"yaml",
}

local treesitter = require("nvim-treesitter")

-- Se declara explícitamente para que estos parsers tengan prioridad sobre
-- restos de instalaciones antiguas dentro del directorio del plugin.
treesitter.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})
treesitter.install(parsers)

-- El filetype personalizado usa el parser de Angular.
vim.treesitter.language.register("angular", "htmlangular")

-- nvim-treesitter no ofrece un parser MDX dedicado; Markdown proporciona
-- resaltado estable para el contenido documental de Storybook.
vim.filetype.add({
	extension = {
		mdx = "markdown",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
	callback = function(args)
		if args.match == "latex" or args.match == "tex" then
			return
		end

		local ok = pcall(vim.treesitter.start, args.buf)
		if ok then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true,
	},
	move = {
		set_jumps = true,
	},
})

local move = require("nvim-treesitter-textobjects.move")
local move_mappings = {
	["]f"] = { move.goto_next_start, "@function.outer", "Ir a la siguiente función" },
	["]c"] = { move.goto_next_start, "@class.outer", "Ir a la siguiente clase" },
	["[f"] = { move.goto_previous_start, "@function.outer", "Ir a la función anterior" },
	["[c"] = { move.goto_previous_start, "@class.outer", "Ir a la clase anterior" },
	["]F"] = { move.goto_next_end, "@function.outer", "Ir al final de la siguiente función" },
	["]C"] = { move.goto_next_end, "@class.outer", "Ir al final de la siguiente clase" },
	["[F"] = { move.goto_previous_end, "@function.outer", "Ir al final de la función anterior" },
	["[C"] = { move.goto_previous_end, "@class.outer", "Ir al final de la clase anterior" },
}

for lhs, mapping in pairs(move_mappings) do
	vim.keymap.set({ "n", "x", "o" }, lhs, function()
		mapping[1](mapping[2], "textobjects")
	end, { desc = mapping[3] })
end

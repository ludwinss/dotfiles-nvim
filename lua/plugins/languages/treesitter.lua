require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"bash",
		"css",
		"dockerfile",
		"elixir",
		"go",
		"html",
		"javascript",
		"json",
		"lua",
		"python",
		"rust",
		"scss",
		"typescript",
		"yaml",
		"c",
		"cpp",
		"vim",
		"regex",
		"markdown",
		"markdown_inline",
		"kdl",
		"make",
	},

	ignore_install = { "latex" },

	sync_install = false,
	auto_install = true,

	highlight = {
		enable = true,
		disable = { "latex", "tex" },
		additional_vim_regex_highlighting = false,
	},

	indent = { enable = true },

	textobjects = {
		select = { enable = true },
		move = {
			enable = true,
			goto_next_start = {
				["]f"] = "@function.outer",
				["]c"] = "@class.outer",
			},
			goto_previous_start = {
				["[f"] = "@function.outer",
				["[c"] = "@class.outer",
			},
			goto_next_end = {
				["]F"] = "@function.outer",
				["]C"] = "@class.outer",
			},
			goto_previous_end = {
				["[F"] = "@function.outer",
				["[C"] = "@class.outer",
			},
		},
	},

	playground = {
		enable = true,
		disable = {},
		updatetime = 25,
		persist_queries = false,
	},
})

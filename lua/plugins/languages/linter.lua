require("lint").linters_by_ft = {
	lua = { "luacheck" },
	python = { "flake8" },
	go = { "golangcilint" },
	html = { "markuplint" },
	vue = { "markuplint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		require("lint").try_lint()
	end,
})

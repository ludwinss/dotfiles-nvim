local lint = require("lint")

lint.linters_by_ft = {
	lua = { "luacheck" },
	python = { "flake8" },
	go = { "golangcilint" },
	html = { "markuplint" },
	vue = { "markuplint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		local names = lint.linters_by_ft[vim.bo.filetype] or {}
		local available = {}

		for _, name in ipairs(names) do
			local ok, linter = pcall(function()
				return lint.linters[name]
			end)
			local cmd = ok and linter and linter.cmd or nil
			if type(cmd) == "function" then
				cmd = cmd()
			end
			if type(cmd) == "string" and vim.fn.executable(cmd) == 1 then
				table.insert(available, name)
			end
		end

		if #available > 0 then
			lint.try_lint(available)
		end
	end,
})

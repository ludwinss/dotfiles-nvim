require("mason-tool-installer").setup({
	ensure_installed = {
		-- "csharpier", Ahora usamos el dotnet tools install csharpier
		"stylua",
		"prettierd",
		"fixjson",
		"sql-formatter",
		"shfmt",
	},
	auto_update = true,
	run_on_start = true,
})

require("mason-tool-installer").setup({
	ensure_installed = {
		-- "csharpier", Ahora usamos el dotnet tools install csharpier
		"stylua",
		"prettierd",
		"prettier",
		"fixjson",
		"markuplint",
		"sql-formatter",
		"shfmt",
		"dart-debug-adapter",
	},
	auto_update = true,
	run_on_start = true,
})

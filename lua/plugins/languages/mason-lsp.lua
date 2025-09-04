local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
	ensure_installed = {
		"cssls",
		"lua_ls",
		"julials",
		"bashls",
		"pyright",
		"rust_analyzer",
		"texlab",
		"yamlls",
		"gopls",
		"terraformls",
		"eslint",
		"tsserver",
		"cmake",
		"dockerls",
		"docker_compose_language_service",
		"html",
		"jsonls",
		"omnisharp",
		"ruff",
	},
	automatic_enable = false,
})

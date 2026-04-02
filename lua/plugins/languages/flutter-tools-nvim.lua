require("flutter-tools").setup({
	lsp = {
		capabilities = require("cmp_nvim_lsp").default_capabilities(),
		on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
			vim.bo[bufnr].formatexpr = ""
		end,
	},
})

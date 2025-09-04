local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function on_attach(client, bufnr)
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
	vim.bo[bufnr].formatexpr = ""
end

local defaults = {
	capabilities = capabilities,
	on_attach = on_attach,
	flags = { debounce_text_changes = 250 },
}

local function setup(server, opts)
	opts = opts or {}
	for k, v in pairs(defaults) do
		if opts[k] == nil then
			opts[k] = v
		end
	end
	lspconfig[server].setup(opts)
end

-- ==================================================================
local omnisharp_bin = vim.fn.stdpath("data") .. "/mason/bin/OmniSharp"

setup("omnisharp", {
	cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
})

-- ==================================================================

setup("lua_ls")
setup("bashls")
setup("pyright")
setup("ruff")
setup("rust_analyzer")
setup("gopls")
setup("cssls")
setup("texlab")
setup("yamlls")
setup("terraformls")
setup("eslint", {
	root_dir = require("lspconfig.util").root_pattern(
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.json",
		"package.json",
		".git"
	),
	settings = { format = false },
})
setup("ts_ls")
setup("cmake")
setup("dockerls")
setup("docker_compose_language_service")
setup("html")
setup("jsonls")

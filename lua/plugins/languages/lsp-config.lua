local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function on_attach(client, bufnr)
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
	vim.bo[bufnr].formatexpr = ""
end

vim.lsp.config("*", {
	capabilities = capabilities,
	on_attach = on_attach,
	flags = { debounce_text_changes = 250 },
})

local omnisharp_bin = vim.fn.stdpath("data") .. "/mason/bin/OmniSharp"
vim.lsp.config("omnisharp", {
	cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
})

vim.lsp.config("eslint", {
	root_markers = {
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.json",
		"package.json",
		".git",
	},
	settings = { format = false },
})

local function project_python()
	local v = vim.fs.joinpath(vim.fn.getcwd(), ".venv", "bin", "python")
	if vim.fn.executable(v) == 1 then
		return v
	end
	return nil
end

vim.lsp.config("pylsp", {
	settings = {
		pylsp = {
			plugins = {
				jedi = { environment = project_python() },
				pyflakes = { enabled = true },
				pycodestyle = { enabled = false },
				rope = { enabled = true },
				rope_autoimport = { enabled = true },
			},
		},
	},
})

vim.lsp.config("ltex", {
	cmd_env = {
		JAVA_TOOL_OPTIONS = "-Djdk.xml.totalEntitySizeLimit=0 --enable-native-access=ALL-UNNAMED",
	},
	filetypes = { "markdown", "tex", "plaintex", "text" },
	settings = {
		ltex = {
			language = "es",
			additionalRules = { enablePickyRules = true, motherTongue = "es" },
			dictionary = { ["es"] = {} },
		},
	},
})

vim.lsp.enable({
	"omnisharp",
	"lua_ls",
	"bashls",
	"pylsp",
	"rust_analyzer",
	"gopls",
	"cssls",
	"texlab",
	"yamlls",
	"terraformls",
	"eslint",
	"ts_ls",
	"cmake",
	"dockerls",
	"docker_compose_language_service",
	"html",
	"jsonls",
	"taplo",
	"marksman",
	"ltex",
	"sqls",
})

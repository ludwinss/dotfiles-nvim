local capabilities = require("cmp_nvim_lsp").default_capabilities()
local mason = require("plugins.languages.mason-lsp")
require("plugins.languages.ltex-nvim")

local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

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

local omnisharp_bin = vim.fs.joinpath(mason_bin, "OmniSharp")
vim.lsp.config("omnisharp", {
	cmd = {
		omnisharp_bin,
		"-z",
		"--hostPID",
		tostring(vim.fn.getpid()),
		"DotNet:enablePackageRestore=false",
		"--encoding",
		"utf-8",
		"--languageserver",
	},
	init_options = {},
	capabilities = vim.tbl_deep_extend("force", capabilities, {
		workspace = {
			workspaceFolders = false,
		},
	}),
	settings = {
		FormattingOptions = {
			EnableEditorConfigSupport = true,
		},
		Sdk = {
			IncludePrereleases = true,
		},
	},
})

vim.lsp.config("eslint", {
	cmd = { vim.fs.joinpath(mason_bin, "vscode-eslint-language-server"), "--stdio" },
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
	return (vim.fn.executable(v) == 1) and v or nil
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
	filetypes = { "markdown", "tex", "plaintex", "gitcommit" },
	settings = {
		ltex = {
			language = "es",
			additionalRules = { enablePickyRules = true, motherTongue = "es" },
			dictionary = { es = {} },
		},
	},
})

vim.lsp.config("ts_ls", {
	cmd = { vim.fs.joinpath(mason_bin, "typescript-language-server"), "--stdio" },
	settings = {
		typescript = { format = { enable = false } },
		javascript = { format = { enable = false } },
	},
})

local ngserver_bin = vim.fs.joinpath(mason_bin, "ngserver")

local function angular_probe_locations(root_dir)
	local probes = {}

	local project_modules = vim.fs.joinpath(root_dir, "node_modules")
	if vim.uv.fs_stat(project_modules) then
		table.insert(probes, project_modules)
	end

	local exe = (vim.fn.executable(ngserver_bin) == 1) and ngserver_bin or vim.fn.exepath("ngserver")
	if exe ~= "" then
		local real = vim.uv.fs_realpath(exe) or exe
		local bundled = vim.fs.normalize(vim.fs.joinpath(vim.fs.dirname(real), "../../.."))
		if vim.uv.fs_stat(bundled) then
			table.insert(probes, bundled)
		end
	end

	return exe, probes
end

vim.lsp.config("angularls", {
	cmd = function(dispatchers, config)
		local root_dir = (config and config.root_dir) or vim.fn.getcwd()
		local exe, probes = angular_probe_locations(root_dir)

		local ng_probes = vim.tbl_map(function(p)
			return vim.fs.joinpath(p, "@angular/language-server/node_modules")
		end, probes)

		return vim.lsp.rpc.start({
			exe,
			"--stdio",
			"--tsProbeLocations",
			table.concat(probes, ","),
			"--ngProbeLocations",
			table.concat(ng_probes, ","),
		}, dispatchers)
	end,
	filetypes = { "typescript", "html", "htmlangular" },
	root_markers = { "angular.json", "nx.json", "project.json" },
})

vim.lsp.enable(mason.servers)

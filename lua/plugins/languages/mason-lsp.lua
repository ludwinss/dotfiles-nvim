local M = {}

local function normalize(name)
	return (name == "tsserver") and "ts_ls" or name
end

M.servers = vim.tbl_map(normalize, {
	"cssls",
	"lua_ls",
	"julials",
	"bashls",
	"pylsp",
	"rust_analyzer",
	"texlab",
	"yamlls",
	"gopls",
	"terraformls",
	"eslint",
	"ts_ls",
	"cmake",
	"dockerls",
	"docker_compose_language_service",
	"html",
	"jsonls",
	"omnisharp",
	"ruff",
	"taplo",
	"marksman",
	"ltex",
	"sqls",
})

function M.setup()
	require("mason").setup()
	require("mason-lspconfig").setup({
		ensure_installed = M.servers,
		automatic_installation = true,
	})
end

return M

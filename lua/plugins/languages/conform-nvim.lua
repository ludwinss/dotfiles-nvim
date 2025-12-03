require("conform").setup({
	notify_on_error = false,

	format_on_save = function(bufnr)
		if vim.g.disable_autoformat then
			return
		end

		local ft = vim.bo[bufnr].filetype
		if ft == "csharp" or ft == "cs" then
			return { timeout_ms = 800, lsp_fallback = false, quiet = true }
		end
		return { timeout_ms = 800, lsp_fallback = true, quiet = true }
	end,

	default_format_opts = { lsp_format = "fallback" },

	formatters_by_ft = {
		lua = { "stylua" },
		rust = { "rustfmt", "lsp" },

		javascript = { "prettierd", "eslint_d" },
		typescript = { "prettierd", "eslint_d" },
		javascriptreact = { "prettierd", "eslint_d" },
		typescriptreact = { "prettierd", "eslint_d" },

		python = { "ruff_format", "ruff_fix" },

		json = { "prettierd", "fixjson" },
		markdown = { "prettierd" },

		csharp = { "csharpier" },
		cs = { "csharpier" },
		toml = { "taplo" },
		sql = { "sql_formatter" },

		shell = { "shfmt" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		mksh = { "shfmt" },

		dart = { "dart" },
	},

	formatters = {
		csharpier = {
			command = "csharpier",
			args = { "format", "--write-stdout" },
			stdin = true,
			condition = function()
				return vim.fn.executable(vim.fn.exepath("csharpier")) == 1
			end,
		},

		eslint_d = {
			condition = function(ctx)
				return vim.fs.find({
					".eslintrc",
					".eslintrc.js",
					".eslintrc.cjs",
					"package.json",
				}, { upward = true, path = ctx.filename })[1] ~= nil
			end,
			prepend_args = { "--fix", "--rule", "prettier/prettier: off" },
		},

		prettierd = {
			condition = function(ctx)
				return vim.fs.find({
					".prettierrc",
					".prettierrc.js",
					"prettier.config.js",
					"package.json",
				}, { upward = true, path = ctx.filename })[1] ~= nil
			end,
		},
	},
})

require("conform").setup({
	notify_on_error = false,

	format_on_save = function(bufnr)
		if vim.g.disable_autoformat then
			return
		end

		local ft = vim.bo[bufnr].filetype
		if ft == "dotenv" or ft == "conf" then
			return
		end
		return { timeout_ms = 800, lsp_fallback = false, quiet = true }
	end,

	default_format_opts = { lsp_format = "never" },

	formatters_by_ft = {
		lua = { "stylua" },
		rust = { "rustfmt" },

		javascript = { "prettierd", "eslint_d", stop_after_first = true },
		typescript = { "prettierd", "eslint_d", stop_after_first = true },
		javascriptreact = { "prettierd", "eslint_d", stop_after_first = true },
		typescriptreact = { "prettierd", "eslint_d", stop_after_first = true },
		vue = { "prettierd", "prettier", stop_after_first = true },

		python = { "ruff_format" },

		json = { "prettierd", "fixjson", stop_after_first = true },
		markdown = { "prettierd" },
		html = { "prettierd", "prettier", stop_after_first = true },

		csharp = { "csharpier" },
		cs = { "csharpier" },
		toml = { "taplo" },
		sql = { "sql_formatter" },

		shell = { "shfmt" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		mksh = { "shfmt" },

		dart = { "dart_format" },
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

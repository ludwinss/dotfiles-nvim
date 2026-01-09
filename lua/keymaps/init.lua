local U = require("utils")
local M = {}

local keymap = vim.keymap.set
local default_opts = { noremap = true, silent = true }

local n, i, v, t = "n", "i", "v", "t"
local n_i = { n, i }
local n_v = { n, v }

function M.init()
	-- M.debugger()
	M.editing()
	M.git()
	M.lsp()
	M.native()
	M.conformkeymap()
	M.oil()
	M.telescope()
	M.editing()
	M.zenmode()
	M.completion()
	M.terminal()
	M.testing()
end

-- dont touch
function M.native()
	keymap(n, "<C-w><C-c>", "<Cmd>wincmd c<CR>", default_opts)
	keymap(n, "<C-h>", "<Cmd>wincmd h<CR>", default_opts)
	keymap(n, "<C-j>", "<Cmd>wincmd j<CR>", default_opts)
	keymap(n, "<C-k>", "<Cmd>wincmd k<CR>", default_opts)
	keymap(n, "<C-l>", "<Cmd>wincmd l<CR>", default_opts)
	keymap(t, "<C-w><C-c>", "<Cmd>wincmd c<CR>", default_opts)
	keymap(t, "<C-h>", "<C-\\><C-n><C-w>h", default_opts)
	keymap(t, "<C-j>", "<C-\\><C-n><C-w>j", default_opts)
	keymap(t, "<C-k>", "<C-\\><C-n><C-w>k", default_opts)
	keymap(t, "<C-l>", "<C-\\><C-n><C-w>l", default_opts)

	keymap(
		n_v,
		"<C-e>",
		"j<C-e>",
		vim.tbl_extend("force", default_opts, {
			desc = "Desplazar hacia abajo",
		})
	)
	keymap(
		n_v,
		"<C-y>",
		"k<C-y>",
		vim.tbl_extend("force", default_opts, {
			desc = "Desplazar hacia arriba",
		})
	)
	keymap(n, "<leader>d", function()
		require("native.lsp-native").toggle_virtual_diagnostics()
		default_opts = vim.tbl_extend("force", default_opts, { desc = "Act/Desc diagnósticos virtuales" })
	end, default_opts)
	keymap(n, "<leader>f", function()
		require("native.lsp-native").toggle_format_enabled()
		default_opts = vim.tbl_extend("force", default_opts, { desc = "Act/Desc formateo" })
	end, default_opts)

	keymap(n, "<leader>c", function()
		require("native.lsp-native").toggle_copilot()
		default_opts = vim.tbl_extend("force", default_opts, { desc = "Act/Desc copilot" })
	end, default_opts)

	keymap(
		n,
		"gm",
		"<Cmd>vertical Man<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Ver página de manual",
		})
	)
	keymap("n", "K", "<nop>", { desc = "Desactivar K por defecto" })
end

--TODO: dont touch
function M.editing()
	keymap(i, "<Esc>", "<Esc>`^", default_opts)
	keymap(v, "<Esc>", "v", default_opts)

	keymap(n, "s", function()
		require("leap").leap({})
	end, vim.tbl_extend("force", default_opts, { desc = "Saltar hacia adelante" }))

	keymap(n, "gs", function()
		require("leap").leap({ backward = true })
	end, vim.tbl_extend("force", default_opts, { desc = "Saltar hacia atrás" }))
	keymap(n, "<leader>m", "<cmd>RenderMarkdown toggle<CR>", { desc = "Previsualizar markdown" })

	keymap(v, "<C-j>", function()
		require("keymaps.utils").select_current_function()
	end, vim.tbl_extend("force", default_opts, { desc = "Seleccionar método" }))
end

--TODO: dont touch
function M.git()
	keymap(
		n,
		"<leader>v",
		function()
			require("keymaps.utils").toggle_diffview()
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Ver diffview",
		})
	)

	keymap(
		n,
		"<leader>b",
		"<Cmd>GitBlameToggle<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Culpa",
		})
	)

	keymap(
		n,
		"<leader>gg",
		function()
			require("keymaps.utils").toggle_neogit()
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Toggle Neogit UI",
		})
	)
end

function M.lsp()
	keymap(
		n,
		"<leader>ca",
		vim.lsp.buf.code_action,
		vim.tbl_extend("force", default_opts, {
			desc = "Acciones de código",
		})
	)

	keymap(
		n,
		"RR",
		function()
			pcall(vim.lsp.buf.rename)
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Renombrar símbolo",
		})
	)

	keymap(
		n,
		"gh",
		function()
			pcall(vim.lsp.buf.hover)
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Documentación flotante",
		})
	)

	keymap(
		n_i,
		"<C-\\>",
		function()
			pcall(vim.lsp.buf.signature_help)
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Ayuda de firma",
		})
	)

	keymap(
		n,
		"ge",
		function()
			require("native.lsp-native").open_diagnostics_float()
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Ventana flotante de diagnósticos",
		})
	)

	keymap(
		n,
		"[e",
		function()
			require("native.lsp-native").prev_diag()
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Diagnóstico anterior",
		})
	)

	keymap(
		n,
		"]e",
		function()
			require("native.lsp-native").next_diag()
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Siguiente diagnóstico",
		})
	)

	keymap(
		n,
		"[E",
		function()
			require("native.lsp-native").prev_error()
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Error anterior",
		})
	)

	keymap(
		n,
		"]E",
		function()
			require("native.lsp-native").next_error()
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Siguiente error",
		})
	)
end

function M.conformkeymap()
	keymap(
		n,
		"<leader>gf",
		function()
			require("conform").format({
				async = true,
				lsp_fallback = true,
			})
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Formatear archivo",
		})
	)
end

function M.telescope()
	keymap(
		n,
		"<leader>fg",
		"<cmd>Telescope live_grep<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Buscar texto en archivos abiertos",
		})
	)
	keymap(
		n,
		"<leader><leader>",
		"<cmd>Telescope oldfiles<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Ver archivos antiguos",
		})
	)

	keymap(
		n,
		"fh",
		function()
			require("telescope.builtin").help_tags({})
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Ver páginas de ayuda",
		})
	)

	keymap(
		n,
		"z=",
		function()
			require("telescope.builtin").spell_suggest({})
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Sugerencias de ortografía",
		})
	)

	keymap(
		n,
		"fk",
		function()
			require("telescope.builtin").keymaps({})
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Ver keymaps",
		})
	)

	keymap(
		n,
		"fj",
		function()
			require("telescope.builtin").jumplist({ cwd = vim.loop.cwd() })
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Ver jumplist",
		})
	)

	keymap(
		n,
		"fm",
		function()
			require("telescope.builtin").man_pages({ sections = { "ALL" } })
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Ver páginas de manual",
		})
	)

	keymap(
		n,
		"ff",
		function()
			require("telescope.builtin").find_files({})
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Buscar archivos (cwd)",
		})
	)

	keymap(
		n,
		"fF",
		function()
			require("telescope.builtin").find_files({ cwd = vim.fn.expand("~") })
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Buscar archivos (home)",
		})
	)

	keymap(
		n,
		"<C-f>",
		function()
			require("telescope.builtin").current_buffer_fuzzy_find({
				previewer = false,
				results_ts_highlight = false,
				wrap_results = false,
			})
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Buscar texto en buffer actual",
		})
	)

	keymap(
		n,
		"<C-n>",
		"<Cmd>Telescope buffers previewer=false<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Ver buffers abiertos",
		})
	)

	keymap(
		n,
		"fd",
		"<Cmd>Telescope diagnostics line_width=full bufnr=0<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Diagnósticos buffer actual",
		})
	)

	keymap(
		n,
		"fD",
		"<Cmd>Telescope diagnostics line_width=full<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Diagnósticos globales",
		})
	)

	keymap(
		n_v,
		"fg",
		function()
			require("telescope.builtin").registers()
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Ver registros",
		})
	)

	keymap(
		n,
		"ft",
		"<Cmd>TodoTelescope previewer=false wrap_results=false<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Ver TODOs",
		})
	)

	keymap(
		n,
		"fT",
		"<Cmd>TodoTelescope previewer=false wrap_results=false cwd=" .. U.get_git_root() .. "<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Ver TODOs (root)",
		})
	)

	keymap(
		n,
		"fs",
		"<Cmd>Telescope lsp_document_symbols<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Símbolos de documento",
		})
	)

	keymap(
		n,
		"gr",
		"<Cmd>Telescope lsp_references<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Referencias LSP",
		})
	)

	keymap(
		n,
		"gd",
		"<Cmd>Telescope lsp_definitions<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Definiciones LSP",
		})
	)

	keymap(
		n,
		"gi",
		"<Cmd>Telescope lsp_implementations<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Buscar implementaciones",
		})
	)
end

-- TODO: dont touch
function M.completion()
	local cmp = require("cmp")
	local luasnip = require("luasnip")
	cmp.setup({
		mapping = cmp.mapping.preset.insert({
			["<C-u>"] = cmp.mapping.scroll_docs(-4),
			["<C-d>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<CR>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					local entry = cmp.get_selected_entry()
					if not entry then
						fallback()
					else
						cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
					end
				else
					fallback()
				end
			end, { "i", "s" }),
			["<C-j>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_locally_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end, { "i", "s" }),
			["<C-k>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),
		}),
	})
end

function M.debugger()
	keymap(
		n,
		"<C-b>",
		"<Cmd>DapToggleBreakpoint<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Poner breakpoint",
		})
	)

	keymap(
		n,
		"<leader>s",
		function()
			require("keymaps.utils").dap_float_scope()
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Ver variables locales",
		})
	)

	keymap(
		n,
		"<F1>",
		function()
			require("keymaps.utils").dap_toggle_ui()
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Abrir UI de debugger",
		})
	)

	keymap(
		n,
		"<leader>dc",
		"<Cmd>DapContinue<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Continuar debugger",
		})
	)

	keymap(
		n,
		"<Right>",
		"<Cmd>DapStepInto<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Entrar en función",
		})
	)

	keymap(
		n,
		"<Down>",
		"<Cmd>DapStepOver<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Saltar función",
		})
	)

	keymap(
		n,
		"<Left>",
		"<Cmd>DapStepOut<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Saltar función",
		})
	)

	keymap(
		n,
		"<Up>",
		"<Cmd>DapRestartFrame<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Reiniciar frame",
		})
	)
end

-- TODO: dont touch
function M.zenmode()
	keymap(
		n,
		"<leader>z",
		"<Cmd>ZenMode<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Activar/Desactivar Zen Mode",
		})
	)
end

-- TODO: dont touch
function M.oil()
	keymap(
		n,
		"<leader>e",
		function()
			require("keymaps.utils").toggle_oil()
		end,
		vim.tbl_extend("force", default_opts, {
			desc = "Abrir explorador de archivos",
		})
	)
end

function M.noice()
	keymap(
		{ "n", "i", "s" },
		"<C-d>",
		function()
			if not require("noice.lsp").scroll(4) then
				return "<C-d>"
			end
		end,
		vim.tbl_extend("force", default_opts, {
			expr = true,
			desc = "Desplazar contenido (down)",
		})
	)

	keymap(
		{ "n", "i", "s" },
		"<C-u>",
		function()
			if not require("noice.lsp").scroll(-4) then
				return "<C-u>"
			end
		end,
		vim.tbl_extend("force", default_opts, {
			expr = true,
			desc = "Desplazar contenido (up)",
		})
	)
end

function M.terminal()
	keymap(n, "tt", "<cmd>ToggleTerm<CR>", vim.tbl_extend("force", default_opts, { desc = "Abrir terminal" }))
end

function M.testing()
	local function with_neotest(fn)
		return function()
			local ok, neotest = pcall(require, "neotest")
			if not ok then
				vim.notify("neotest no está instalado o no se pudo cargar", vim.log.levels.WARN)
				return
			end
			fn(neotest)
		end
	end

	keymap(
		"n",
		"<leader>ta",
		with_neotest(function(neotest)
			neotest.run.run({ suite = true, strategy = "overseer" })
		end),
		vim.tbl_extend("force", default_opts, {
			desc = "Neotest: ejecutar toda la suite del proyecto",
		})
	)

	keymap(
		"n",
		"gt",
		with_neotest(function(neotest)
			neotest.run.run({
				strategy = "overseer",
			})
		end),
		vim.tbl_extend("force", default_opts, {
			desc = "Neotest: ejecutar test más cercano",
		})
	)
	keymap(
		"n",
		"<leader>ts",
		with_neotest(function(neotest)
			require("keymaps.utils").toggle_test_views(neotest)
		end),
		vim.tbl_extend("force", default_opts, {
			desc = "Neotest/Overseer: mostrar/ocultar resumen y panel juntos",
		})
	)

	keymap(
		"n",
		"<leader>tc",
		"<cmd>OverseerRun<CR>",
		vim.tbl_extend("force", default_opts, {
			desc = "Overseer: ejecutar comando o tarea",
		})
	)
end
return M

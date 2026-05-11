local TS = require("telescope")
local U = require("utils")

local prompt_chars = U.border_chars_telescope_default
local vert_preview_chars = U.border_chars_telescope_default
if not U.is_default() then
	prompt_chars = U.border_chars_telescope_prompt_thin
	vert_preview_chars = U.border_chars_telescope_vert_preview_thin
end

local picker_buffer = {
	preview = false,
	wrap_results = false,
	layout_config = {
		height = 0.4,
		width = 0.5,
	},
	sort_mru = true,
	ignore_current_buffer = true,
	file_ignore_patters = { "\\." },
	on_complete = {
		function(picker)
			vim.schedule(function()
				picker:set_selection(0)
			end)
		end,
	},
}

local picker_register = {
	sort_mru = true,
	preview = false,
	wrap_results = false,
	layout_config = {
		height = 0.6,
		width = 0.6,
	},
}

local small_lsp_layout = {
	layout_strategy = "vertical",
	preview_title = "",
	previewer = false,
	wrap_results = false,
	layout_config = {
		height = 0.75,
		width = 0.65,
		mirror = true,
	},
	borderchars = {
		prompt = prompt_chars,
		preview = vert_preview_chars,
		results = U.get_border_chars("telescope"),
	},
}

local defaults = {
	layout_strategy = "vertical",
	preview_title = "",
	dynamic_preview_title = false,
	previewer = true,

	layout_config = {
		prompt_position = "top",
		mirror = true,
		height = 0.95,
		width = 0.75,
		preview_cutoff = 1,
		vertical = {
			preview_height = 0.55,
			preview_cutoff = 1,
		},
	},

	borderchars = {
		prompt = prompt_chars,
		preview = vert_preview_chars,
		results = U.get_border_chars("telescope"),
	},

	sort_mru = true,
	sorting_strategy = "ascending",
	border = true,
	multi_icon = "",
	entry_prefix = "   ",
	prompt_prefix = "   ",
	selection_caret = "  ",
	hl_result_eol = true,
	results_title = "",
	winblend = 0,
	wrap_results = true,
	mappings = {
		n = {
			["q"] = require("telescope.actions").close,
			["j"] = require("telescope.actions").move_selection_next,
			["k"] = require("telescope.actions").move_selection_previous,
		},
	},

	-- BUG: This causes too many issues.
	preview = { treesitter = false },
}

TS.setup({
	defaults = defaults,
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({
				layout_strategy = "center",
				layout_config = {
					width = 0.4,
					height = 0.3,
				},
			}),
		},
	},
	pickers = {
		diagnostics = { sort_by = "severity", preview_title = "" },
		buffers = picker_buffer,
		registers = picker_register,

		lsp_definitions = small_lsp_layout,
		lsp_references = small_lsp_layout,
		lsp_implementations = small_lsp_layout,

		live_grep = {
			preview_title = "",
			previewer = true,
			cwd = U.current_work_dir(),
		},
		help_tags = {
			preview_title = "",
			previewer = true,
			mappings = { i = { ["<CR>"] = require("telescope.actions").select_vertical } },
		},
		oldfiles = {
			preview_title = "",
			previewer = true,
			cwd = U.current_work_dir(),
		},
		find_files = {
			preview_title = "",
			previewer = true,
			cwd = U.current_work_dir(),
		},
		lsp_document_symbols = { preview_title = "", previewer = false },
		man_pages = {
			preview_title = "",
			previewer = true,
			mappings = { i = { ["<CR>"] = require("telescope.actions").select_vertical } },
		},
	},
})

vim.api.nvim_create_autocmd("User", {
	pattern = "TelescopePreviewerLoaded",
	callback = function()
		vim.opt_local.number = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "TelescopePrompt", "TelescopeResults" },
	callback = function()
		require("keymaps.utils").close_all_oil_windows()
	end,
})

TS.load_extension("ui-select")

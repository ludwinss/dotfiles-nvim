local oil = require("oil")

oil.setup({
	default_file_explorer = true,
	columns = {
		"icon",
	},
	float = {
		padding = 0,
		max_width = 80,
		max_height = 30,
		border = "rounded",
		win_options = {
			winblend = 0,
		},
	},
	keymaps = {
		["<CR>"] = "actions.select",
		["-"] = "actions.parent",
		["<C-v>"] = "actions.select_vsplit",
		["<C-x>"] = "actions.select_split",
		["<C-t>"] = "actions.select_tab",
	},
	use_default_keymaps = false,
	view_options = {
		show_hidden = true,
		is_always_hidden = function(name, _)
			return name == ".." or name == ".git"
		end,
	},
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "oil",
	callback = function()
		vim.wo.signcolumn = "no"
		vim.wo.foldcolumn = "0"
		vim.wo.number = true
		vim.wo.relativenumber = false
		vim.wo.statuscolumn = "%l "
		vim.wo.numberwidth = 3
		vim.keymap.set("n", "q", "<cmd>bd!<CR>", { buffer = true, desc = "Cerrar Oil" })
	end,
})

local C = require("utils.ui")
local U = require("utils.nvim")

vim.g.mapleader = " "

vim.opt.showmode = false
vim.opt.clipboard:append("unnamedplus")
vim.opt.swapfile = false
vim.opt.mouse = "a"
vim.opt.hlsearch = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.textwidth = 0

vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.showtabline = 0

-- Pliegues estructurales para JSON y el resto de lenguajes con Treesitter.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "1"

vim.opt.inccommand = "nosplit"

vim.opt.cmdheight = 0
vim.g.VM_set_statusline = 0
vim.g.VM_silent_exit = 1

vim.o.termguicolors = true

if not U.is_default() then
	vim.opt.fillchars = {
		horiz = C.bottom_thin,
		horizup = C.bottom_thin,
		horizdown = C.right_thick,
		vert = C.right_thick,
		vertleft = C.right_thick,
		vertright = C.right_thick,
		verthoriz = C.right_thick,
	}
else
	vim.opt.fillchars = {
		eob = " ",
		diff = "╱",
		vert = C.right_thick,
		vertleft = C.right_thick,
		vertright = C.right_thick,
		verthoriz = C.right_thick,
		horiz = C.bottom_thin,
		horizup = C.bottom_right_thin,
	}
end

-- Numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

-- Cursor
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

-- Windows
vim.opt.winblend = 0
vim.opt.pumblend = 0
vim.opt.pumheight = 10

vim.opt.background = "dark"

vim.filetype.add({
	pattern = {
		[".*%.component%.html"] = "htmlangular",
	},
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("JsonTreesitterFolds", { clear = true }),
	pattern = { "json", "jsonc" },
	callback = function(args)
		vim.opt_local.foldmethod = "expr"
		vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.opt_local.foldenable = true
		vim.opt_local.foldlevel = 99

		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(args.buf) or vim.api.nvim_get_current_buf() ~= args.buf then
				return
			end

			pcall(vim.treesitter.start, args.buf)
			local ok, parser = pcall(vim.treesitter.get_parser, args.buf)
			if ok then
				parser:parse(true)
				vim.cmd("silent! normal! zx")
			end
		end)
	end,
})

vim.cmd("filetype plugin indent on")

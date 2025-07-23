local C = require("utils.ui")
local U = require("utils.nvim")

vim.g.mapleader = " "

vim.opt.showmode = false
vim.opt.clipboard:append("unnamedplus")
vim.opt.swapfile = false
vim.opt.mouse = ""
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

vim.cmd("filetype plugin indent on")

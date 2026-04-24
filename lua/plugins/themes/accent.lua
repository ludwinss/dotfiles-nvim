local common = require("plugins.themes.common")

vim.g.accent_colour = "yellow"
vim.g.accent_darken = 1
vim.g.accent_invert_status = 1
vim.g.accent_no_bg = 0
vim.g.accent_auto_cwd_colour = 0

common.attach("accent", {
	accent = "#56b6c2",
	accent_alt = "#e5c07b",
	border = "#56b6c2",
	muted = "#777777",
})

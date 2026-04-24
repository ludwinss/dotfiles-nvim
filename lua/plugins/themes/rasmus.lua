local common = require("plugins.themes.common")

vim.g.rasmus_italic_comments = true
vim.g.rasmus_italic_functions = true
vim.g.rasmus_bold_functions = true
vim.g.rasmus_transparent = false
vim.g.rasmus_variant = "dark"

common.attach("rasmus", {
	accent = "#88c0d0",
	accent_alt = "#b48ead",
	border = "#5f7289",
	muted = "#6f7f94",
})

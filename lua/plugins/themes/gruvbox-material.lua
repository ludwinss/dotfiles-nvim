local common = require("plugins.themes.common")

vim.g.gruvbox_material_background = "medium"
vim.g.gruvbox_material_foreground = "material"
vim.g.gruvbox_material_enable_italic = 1
vim.g.gruvbox_material_sign_column_background = "none"
vim.g.gruvbox_material_menu_selection_background = "grey"
vim.g.gruvbox_material_transparent_background = 0

common.attach("gruvbox-material", {
	accent = "#d8a657",
	accent_alt = "#7daea3",
	border = "#7c6f64",
	muted = "#928374",
})

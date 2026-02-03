local theme = {}
local ok, palette = pcall(require, "nordic.colors")
if ok then
	theme.normal = { fg = palette.white0_normal }
	theme.alt = { fg = palette.gray5 }
end

require("leetcode").setup({
	lang = "rust",
	theme = theme,
})

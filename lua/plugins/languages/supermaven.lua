require("supermaven-nvim").setup({
	disable_inline_completion = false,
	disable_keymaps = true,
	ignore_filetypes = {
		"TelescopePrompt",
		"dashboard",
		"help",
		"lazy",
		"mason",
		"noice",
		"notify",
		"oil",
		"prompt",
		"qf",
		"terminal",
	},
	log_level = "warn",
})

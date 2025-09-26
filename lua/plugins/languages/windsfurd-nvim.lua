require("codeium").setup({
	virtual_text = {
		enabled = true,
		idle_delay = 75,
		key_bindings = {
			accept = "<Tab>",
			next = "<M-]>",
			prev = "<M-[>",
			clear = "<C-]>",
			accept_word = "<C-j>",
			accept_line = "<C-k>",
		},
	},

	enable_cmp_source = false,
})

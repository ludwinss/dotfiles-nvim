require("codeium").setup({
	virtual_text = {
		enabled = true,
		idle_delay = 75,
		-- Los atajos se resuelven junto con CMP en completitions.lua.
		map_keys = false,
	},

	enable_cmp_source = false,
})

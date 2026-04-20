local leap = require("leap")

vim.keymap.set({ "n", "x", "o" }, "s", function()
	leap.leap({ target_windows = { vim.api.nvim_get_current_win() } })
end)

vim.keymap.set({ "n", "x", "o" }, "S", function()
	leap.leap({ backward = true })
end)

local neotest = require("neotest")
neotest.setup({
	adapters = {
		require("neotest-go"),
		require("neotest-python")({ dap = { justMyCode = false } }),
		require("neotest-jest")({ jestCommand = "npm test --", env = { CI = true } }),
		require("neotest-rust")({ args = { "--nocapture" } }),
	},
	quickfix = { open = false },
	output = { enabled = true, open_on_run = true },
	summary = { follow = true },
})

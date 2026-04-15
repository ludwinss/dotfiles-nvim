local F = require("keymaps.utils")

vim.api.nvim_create_user_command("LtexLang", function(opts)
	F.switch_ltex_lang(opts.args)
end, {
	nargs = 1,
	complete = function()
		return { "es", "en-US", "pt-BR" }
	end,
})

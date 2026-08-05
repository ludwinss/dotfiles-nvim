require("gitblame").setup({
	enabled = false,
	date_format = "%d/%m/%Y %H:%M",
	message_template = "  <author> • <date> • <summary>",
	message_when_not_committed = "  Sin commitear",
	virtual_text_column = nil,
})

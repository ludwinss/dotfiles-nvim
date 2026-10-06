local ls = require("luasnip")

local snippet = ls.snippet
local insert = ls.insert_node
local text = ls.text_node

return {
	snippet("pp", {
		text('println!("{:?}", '),
		insert(1, "value"),
		text(");"),
	}),
}

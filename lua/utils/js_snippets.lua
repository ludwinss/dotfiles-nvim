local ls = require("luasnip")
local rep = require("luasnip.extras").rep

local snippet = ls.snippet
local insert = ls.insert_node
local text = ls.text_node

return function()
	return {
		snippet({ trig = "cl", priority = 1001 }, {
			text('console.log("'),
			rep(1),
			text(': ", '),
			insert(1, "value"),
			text(");"),
		}),
	}
end

return {
	name = "luasnip",
	dir = "@luasnip@",
	config = function()
		local ls = require("luasnip")
		local s = ls.snippet
		local t = ls.text_node

		ls.config.setup({
			enable_autosnippets = true,
		})

		-- Unicode input using Lean's abbreviation syntax
		-- Reference: https://github.com/leanprover/vscode-lean4/blob/master/lean4-unicode-input/src/abbreviations.json
		local abbreviations = {
			{ "\\vdash", "⊢" },
			{ "\\Rightarrow", "⇒" },
		}

		local snippets = {}
		local autosnippets = {}

		for _, abbr in ipairs(abbreviations) do
			local trigger, symbol = abbr[1], abbr[2]
			-- Regular snippet for completion menu
			table.insert(snippets, s({ trig = trigger, desc = symbol }, { t(symbol) }))
			-- Autosnippet for immediate expansion
			table.insert(autosnippets, s({ trig = trigger, snippetType = "autosnippet" }, { t(symbol) }))
		end

		ls.add_snippets("all", snippets)
		ls.add_snippets("all", autosnippets)
	end,
}

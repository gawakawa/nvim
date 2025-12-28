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
		local snippets = {
			s({ trig = "\\vdash", snippetType = "autosnippet" }, { t("⊢") }),
		}

		ls.add_snippets("all", snippets)
	end,
}

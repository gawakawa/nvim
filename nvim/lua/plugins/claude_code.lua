return {
	name = "claude-code.nvim",
	dir = "@claude_code_nvim@",
	dependencies = {
		{ name = "plenary.nvim", dir = "@plenary_nvim@" },
	},
	lazy = false,
	config = function()
		require("claude-code").setup()
	end,
}

return {
	name = "nvim-lint",
	dir = "@nvim_lint@",
	event = { "BufWritePost" },
	config = function()
		require("lint").linters_by_ft = {
			sh = { "shellcheck" },
			bash = { "shellcheck" },
			python = { "ruff" },
			haskell = { "hlint" },
			terraform = { "tflint" },
		}

		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			callback = function()
				require("lint").try_lint()
			end,
		})
	end,
}

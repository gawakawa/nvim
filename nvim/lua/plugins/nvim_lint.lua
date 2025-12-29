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

		local js_fts = {
			typescript = true,
			typescriptreact = true,
			javascript = true,
			javascriptreact = true,
		}

		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			callback = function()
				local lint = require("lint")
				local ft = vim.bo.filetype

				if js_fts[ft] then
					local has_deno = vim.fs.find({ "deno.json", "deno.jsonc" }, {
						path = vim.fn.expand("%:p:h"),
						upward = true,
					})[1]
					lint.try_lint(has_deno and "deno" or "oxlint")
				else
					lint.try_lint()
				end
			end,
		})
	end,
}

return {
	dir = "@rustowl@",
	lazy = false,
	init = function()
		-- ftplugin より先に実行される init で設定
		-- opts/setup() はタイミングが保証されないため使わない
		vim.g.rustowl = {
			auto_attach = false,
			auto_enable = false,
		}
	end,
	keys = {
		{
			"<leader>o",
			function()
				local ra_clients = vim.lsp.get_clients({ name = "rust_analyzer" })
				if #ra_clients > 0 then
					-- rust-analyzer を完全に停止
					for _, c in ipairs(ra_clients) do
						c:stop(true)
					end
					-- 停止を待ってから rustowl を起動
					vim.defer_fn(function()
						require("rustowl.lsp").start()
						require("rustowl").enable()
					end, 100)
				else
					-- rustowl を完全に停止
					local rustowl_clients = vim.lsp.get_clients({ name = "rustowl" })
					for _, c in ipairs(rustowl_clients) do
						c:stop(true)
					end
					-- 停止を待ってから rust-analyzer を起動
					vim.defer_fn(function()
						vim.cmd("LspStart rust_analyzer")
					end, 100)
				end
			end,
			ft = "rust",
			desc = "Toggle RustOwl / rust-analyzer",
		},
	},
}

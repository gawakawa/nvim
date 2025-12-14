return {
	dir = "@rustowl@",
	lazy = false,
	config = function()
		require("rustowl").setup({
			client = {
				on_attach = function(_, buffer)
					vim.keymap.set("n", "<leader>ur", function()
						require("rustowl").toggle(buffer)
					end, { buffer = buffer, desc = "Toggle RustOwl" })
				end,
			},
		})

		local colors = {
			lifetime = "#00cc00",
			imm_borrow = "#0000cc",
			mut_borrow = "#cc00cc",
			move = "#cccc00",
			call = "#cccc00",
			outlive = "#cc0000",
		}
		for name, color in pairs(colors) do
			vim.api.nvim_set_hl(0, name, { sp = color, underline = true, fg = color })
		end
	end,
}

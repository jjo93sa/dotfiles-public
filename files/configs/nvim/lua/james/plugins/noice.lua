return {
	"folke/noice.nvim",
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		local keymap = vim.keymap
		keymap.set("n", "<leader>nd", "<cmd>Noice dismiss<CR>", { desc = "Hide all visible Noice messages" })
		keymap.set("n", "<leader>nh", "<cmd>Noice history<CR>", { desc = "Show Noice history" })
		require("noice").setup({
			-- add any options here
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
							{ find = "%d fewer lines" },
							{ find = "%d more lines" },
						},
					},
					opts = { skip = true },
				},
			},
		})
	end,
}

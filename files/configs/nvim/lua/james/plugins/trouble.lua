return {
	"folke/trouble.nvim",
	opts = {},
	dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
	cmd = "Trouble",
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Open/close trouble list" },
	},
}

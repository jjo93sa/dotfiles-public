return {

	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "*",
	lazy = false,
	priority = 500,
	opts = {
		options = {
			mode = "tabs",
			diagnostics = "nvim_lsp",
			separator_style = "slant",
			buffer_close_icon = "✖",
		},
	},
}

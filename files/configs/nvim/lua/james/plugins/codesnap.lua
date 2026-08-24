return {
	name = "codesnap.nvim",
	dir = vim.fn.stdpath("data") .. "/site/pack/hm/start/codesnap.nvim",
	config = function()
		require("codesnap").setup({
			border = "rounded",
			has_breadcrumbs = true,
			bg_theme = "grape",
			watermark = "",
		})
	end,
}

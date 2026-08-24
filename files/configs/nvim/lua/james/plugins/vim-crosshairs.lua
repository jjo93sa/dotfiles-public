return {
	"bronson/vim-crosshairs",
	lazy = false,
	init = function()
		vim.cmd([[  set cursorline  ]])
		vim.cmd([[  set cursorcolumn  ]])
		vim.opt.cursorline = true
		vim.opt.cursorcolumn = true
	end,
}

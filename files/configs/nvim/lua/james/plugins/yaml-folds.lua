return {
	"pedrohdz/vim-yaml-folds",
	lazy = false,
	config = function()
		vim.cmd([[ set foldlevelstart=99 ]])
		--  vim.cmd([[  set cursorline  ]])
		--  vim.cmd([[  set cursorcolumn  ]])
		--  vim.opt.cursorline = true
		--  vim.opt.cursorcolumn = true
	end,
}

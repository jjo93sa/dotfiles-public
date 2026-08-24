return {
	"pearofducks/ansible-vim",
	lazy = false,
	config = function()
		vim.cmd([[ highlight link yamlFlowString Normal ]])
		vim.cmd([[ highlight link yamlString Normal ]])
		--  vim.cmd([[  set cursorline  ]])
		--  vim.cmd([[  set cursorcolumn  ]])
		--  vim.opt.cursorline = true
		--  vim.opt.cursorcolumn = true
	end,
}

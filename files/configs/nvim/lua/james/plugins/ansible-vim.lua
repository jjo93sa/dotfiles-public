return {
	"pearofducks/ansible-vim",
	lazy = false,
	config = function()
		local ansible

		local function setup_treesitter()
			-- ansible-vim uses the Jinja parser as the outer Ansible parser and
			-- injects YAML between template expressions. Parser installation is
			-- asynchronous, so only initialise it once Jinja is available.
			if #vim.api.nvim_get_runtime_file("parser/jinja.*", false) > 0 then
				if not ansible then
					local modules = vim.api.nvim_get_runtime_file("lua/ansible/init.lua", false)
					ansible = modules[1] and dofile(modules[1])
				end
				if ansible then
					ansible.setup()
				end
			end
		end

		setup_treesitter()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "ansible",
			desc = "Enable Ansible Treesitter integration once its parser is available",
			callback = setup_treesitter,
		})

		vim.cmd([[ highlight link yamlFlowString Normal ]])
		vim.cmd([[ highlight link yamlString Normal ]])
		--  vim.cmd([[  set cursorline  ]])
		--  vim.cmd([[  set cursorcolumn  ]])
		--  vim.opt.cursorline = true
		--  vim.opt.cursorcolumn = true
	end,
}

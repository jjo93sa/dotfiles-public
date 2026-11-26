-- Private configurations can identify a complete Ansible workspace without
-- teaching this public configuration about a company-specific path. Projects
-- elsewhere can opt in by placing an .ansible-project marker at their root.
vim.filetype.add({
	pattern = {
		["${DOTFILES_ANSIBLE_ROOT}/.*%.ya?ml"] = { "yaml.ansible", { priority = 100 } },
		[".*%.ya?ml"] = {
			function(path)
				local marker = vim.fs.find(".ansible-project", {
					path = vim.fs.dirname(path),
					upward = true,
					type = "file",
				})[1]
				if marker then
					return "yaml.ansible"
				end
			end,
			{ priority = 50 },
		},
	},
})

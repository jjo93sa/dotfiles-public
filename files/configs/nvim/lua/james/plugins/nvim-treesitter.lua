return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		branch = "main",
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"windwp/nvim-ts-autotag",
		},
		config = function()
			local treesitter = require("nvim-treesitter")
			vim.treesitter.language.register("jinja", "jinja2")

			local parsers = {
				-- Primary infrastructure and documentation languages.
				"python",
				"yaml",
				"hcl",
				"terraform",
				"jinja",
				"jinja_inline",
				"markdown",
				"markdown_inline",

				-- Other languages used by the shared configuration.
				"json",
				"javascript",
				"typescript",
				"tsx",
				"html",
				"css",
				"prisma",
				"svelte",
				"graphql",
				"bash",
				"lua",
				"nix",
				"vim",
				"dockerfile",
				"gitignore",
				"query",
			}

			-- Parser installation is asynchronous. A parser can be present without
			-- its highlighting query, so check for both before requesting an install.
			local missing = vim.tbl_filter(function(parser)
				return #vim.api.nvim_get_runtime_file("parser/" .. parser .. ".*", false) == 0
					or #vim.api.nvim_get_runtime_file("queries/" .. parser .. "/highlights.scm", false) == 0
			end, parsers)
			if #missing > 0 then
				-- force also repairs an installed parser whose query is missing.
				treesitter.install(missing, { force = true })
			end

			vim.api.nvim_create_autocmd("FileType", {
				desc = "Enable Treesitter highlighting, indentation, and folding when available",
				callback = function(args)
					if pcall(vim.treesitter.start, args.buf) then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

						local filetype = vim.bo[args.buf].filetype
						local language = vim.treesitter.language.get_lang(filetype) or filetype
						if filetype == "yaml" then
							-- Keep the existing indentation-aware YAML folding plugin.
						elseif vim.treesitter.query.get(language, "folds") then
							vim.wo.foldmethod = "expr"
							vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
							vim.wo.foldlevel = 99
						else
							-- Window-local fold settings otherwise leak when changing buffers.
							vim.wo.foldmethod = "manual"
						end
					end
				end,
			})

			require("nvim-ts-autotag").setup({})
			require("ts_context_commentstring").setup({})
		end,
	},
}

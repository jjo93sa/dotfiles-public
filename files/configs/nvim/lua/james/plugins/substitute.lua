return {
	"gbprod/substitute.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local substitute = require("substitute")

		substitute.setup()

		-- The standard substitute keys are configured in core/keymaps.lua so that
		-- removed text goes to register d without replacing the system clipboard.
	end,
}

return {
	"L3MON4D3/LuaSnip",
	config = function()
		local luasnip = require("luasnip")

		luasnip.config.set_config({
			history = true,
			updateevents = "TextChanged,TextChangedI",
			enable_autosnippets = true,
		})

		vim.keymap.set({ "i", "s" }, "<Tab>", function()
			if luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
			end
		end)

		vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
			if luasnip.jumpable(-1) then
				luasnip.jump(-1)
			end
		end)

		vim.keymap.set({ "i", "s" }, "<C-E>", function()
			if luasnip.choice_active() then
				luasnip.change_choice(1)
			end
		end)
		local fmt = require("luasnip.extras.fmt").fmt

		local s = luasnip.snippet
		local t = luasnip.text_node
		local i = luasnip.insert_node
		local c = luasnip.choice_node
		local f = luasnip.function_node
		local d = luasnip.dynamic_node
		local sn = luasnip.snippet_node

		local foo = s("bar", t("baz"))
		local trig = s({ trig = "(%d+)add", regTrig = true }, {
			i(1, "0"),
			t(" + "),
			d(2, function(_, snip)
				return sn(1, { i(1, snip.captures[1]) })
			end, 1),
			t(" = "),
			f(function(args, _)
				return tostring(tonumber(args[1][1]) + tonumber(args[2][1]))
			end, { 1, 2 }),
		})
		local ft = s("ft", {
			c(1, {
				sn(nil, { i(1, "# vim: set ft=yaml.ansible:") }),
				sn(nil, { i(1, "# vim: set ft=yaml:") }),
				sn(nil, { i(1, "# vim: set ft=lua:") }),
				sn(nil, { i(1, "# vim: set ft=python:") }),
			}),
		})
		local ansible = s("ansible.builtin.", {
			t("ansible.builtin."),
			i(1, "debug"),
		})
		local task = s(
			"- name",
			fmt(
				[[
        - name: {}
          ansible.builtin.{}
        ]],
				{
					i(1, "name goes here"),
					i(2, "module goes here"),
				}
			)
		)
		local header = s(
			"---",
			fmt(
				[[
        ---
        - name: {}
          hosts: {}
          become: {}
          gather_facts: {}
        ]],
				{
					i(1, "Playbook name goes here"),
					c(2, {
						t("all"),
						i(nil, "Host pattern goes here"),
					}),
					c(3, {
						t("true"),
						t("false"),
					}),
					c(4, {
						t("true"),
						t("false"),
					}),
				}
			)
		)

		luasnip.add_snippets("all", { foo, ft, trig })
		luasnip.add_snippets("ansible", { ansible, task, header })
	end,
}

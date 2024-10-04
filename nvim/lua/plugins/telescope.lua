return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{
				"nvim-telescope/telescope-ui-select.nvim",
				config = function()
					require("telescope").setup({
						extensions = {
							["ui-select"] = {
								require("telescope.themes").get_dropdown({}),
							},
						},
					})
					require("telescope").load_extension("ui-select")
				end,
			},
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{
				"nvim-telescope/telescope-live-grep-args.nvim",
				version = "^1.0.0",
				config = function()
					local telescope = require("telescope")
					local lga_actions = require("telescope-live-grep-args.actions")
					require("telescope").setup({
						extensions = {
							live_grep_args = {
								auto_quoting = true,
								mappings = {
									i = {
										["<C-k>"] = lga_actions.quote_prompt(),
										["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
									},
								},
							},
						},
					})

					telescope.load_extension("live_grep_args")
					vim.keymap.set("n", "<leader>fg", telescope.extensions.live_grep_args.live_grep_args)
				end,
			},
		},
		opts = {},
		config = function()
			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
			-- vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
			vim.keymap.set("n", "<leader>fd", builtin.diagnostics, {})
		end,
	},
}

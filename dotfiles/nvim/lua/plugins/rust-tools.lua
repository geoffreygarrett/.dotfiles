-- ~/.config/nvim/lua/plugins/rust-tools.lua

return {
	"simrat39/rust-tools.nvim",
	dependencies = { "neovim/nvim-lspconfig" }, -- Ensure that LSPConfig is loaded
	config = function()
		local rt = require("rust-tools")

		rt.setup({
			server = {
				on_attach = function(_, bufnr)
					-- Hover actions
					vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
					-- Code action groups
					vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
				end,
				settings = {
					["rust-analyzer"] = {
						checkOnSave = {
							command = "clippy", -- Use Clippy for checking code on save
						},
					},
				},
			},
			dap = {
				adapter = require("rust-tools.dap").get_codelldb_adapter(
					"/usr/bin/codelldb", -- Correct path to codelldb
					"/usr/lib/liblldb.so" -- Correct path to liblldb.so
				),
			},
		})
	end,
}

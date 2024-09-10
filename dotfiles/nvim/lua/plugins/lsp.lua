-- ~/.config/nvim/lua/plugins/lsp.lua

return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- Basic setup for an LSP server, for example, setting up `rust_analyzer`
			require("lspconfig").rust_analyzer.setup({
				-- Example configuration, add your LSP-specific configurations here
				on_attach = function(_, bufnr)
					-- Key mappings specific to LSP functionality
					local opts = { noremap = true, silent = true, buffer = bufnr }
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				end,
				flags = {
					debounce_text_changes = 150,
				},
				settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
						},
					},
				},
			})

			-- Setup other LSP servers similarly
			-- require('lspconfig').pyright.setup{}
		end,
	},
}

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugins" },
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
	-- Package manager for LSP servers, DAPs, linters, and formatters
	{ "williamboman/mason.nvim" },
	{ "williamboman/mason-lspconfig.nvim" },

	-- LSP support
	{ "neovim/nvim-lspconfig" },

	-- Rust-specific tools
	{ "simrat39/rust-tools.nvim" },

	-- Autocompletion
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "hrsh7th/vim-vsnip" },
	{ "hrsh7th/cmp-vsnip" },

	-- Tree-sitter for syntax highlighting
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

	-- Debugging
	{ "puremourning/vimspector" },

	-- Terminal integration
	{ "voldikss/vim-floaterm" },

	-- Telescope for fuzzy finding
	{ "nvim-telescope/telescope.nvim" },
	{ "nvim-lua/plenary.nvim" },

	-- Additional utilities
	{ "phaazon/hop.nvim" },
	{ "kyazdani42/nvim-tree.lua" },
	{ "preservim/tagbar" },
	{ "folke/todo-comments.nvim" },
	{ "folke/trouble.nvim" },
	{ "lukas-reineke/indent-blankline.nvim" },
	{ "windwp/nvim-autopairs" },
	{ "tpope/vim-surround" },
})

-- ~/.config/nvim/lua/plugins/rust.lua

return {
  "neovim/nvim-lspconfig",
  config = function()
    -- Setup completeopt for a better completion experience
    vim.o.completeopt = "menuone,noinsert,noselect"
    vim.opt.shortmess:append("c")

    -- LSP settings
    local function on_attach(client, bufnr)
      -- Setup buffer-local keymaps, etc.
    end

    local lsp_opts = {
      tools = {
        runnables = {
          use_telescope = true,
        },
        inlay_hints = {
          auto = true,
          show_parameter_hints = false,
          parameter_hints_prefix = "",
          other_hints_prefix = "",
        },
      },
      server = {
        on_attach = on_attach,
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",  -- Use Clippy for checking code on save
            },
          },
        },
      },
    }

    require("rust-tools").setup(lsp_opts)

    -- Setup nvim-cmp for autocompletion
    local cmp = require("cmp")
    cmp.setup({
      preselect = cmp.PreselectMode.None,
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end,
      },
      mapping = {
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = true,
        }),
      },
      sources = {
        { name = "nvim_lsp" },
        { name = "vsnip" },
        { name = "path" },
        { name = "buffer" },
      },
    })
  end,
}
